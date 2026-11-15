extends Node

const SAVE_PATH := "user://woven_settings.cfg"

# --- TAB 1: VIDEO & DISPLAY ---
var fullscreen: bool = true
var base_resolution := Vector2i(1920, 1080)
var resolution_index: int = 1
var resolution_scale: float = 1.0
var fps_limit: int = 0
var language: String = "en_US"
var effects_enabled: bool = true
var colour_mode: bool = false
var screen_filter: int = 0
var streamer_mode: bool = false
var screen_shake: float = 1.0
var flash_reduction: bool = false

# --- TAB 2: CONTROLS & GAMEPLAY ---
var auto_skip_cutscenes: bool = false
var show_dialog_boxes: bool = true
var text_speed: int = 1
var auto_advance_dialog: bool = false
var toggle_block: bool = false

# --- TAB 3: SOUND & AUDIO ---
var master_vol: float = 1.0
var music_vol: float = 1.0
var sfx_vol: float = 1.0
var dialog_vol: float = 1.0
var mono_audio: bool = false
var subtitle_mode: int = 1
var mute_unfocused: bool = true

# --- TAB 4: SECRET VARIABLES ---
var unlocked_cheats: Dictionary = {}

const RESOLUTIONS: Array[Vector2i] = [
	Vector2i(1920, 1080),
	Vector2i(1280, 720),
	Vector2i(3840, 2160),
	Vector2i(1600, 900),
	Vector2i(1024, 576)
]

var FPS_OPTIONS := PackedInt32Array([0, 60, 30])

func _ready() -> void:
	load_settings()
	if OS.has_feature("editor"):
		fullscreen = true
	apply_all_settings.call_deferred()
# Forces exclusive fullscreen on boot
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	
	# Runs your new scaler at 100% (1.0) right away
	apply_resolution_scale(1.0)

func _notification(what: int) -> void:
	if not mute_unfocused:
		return
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		AudioServer.set_bus_mute(0, true)
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		AudioServer.set_bus_mute(0, false)

func apply_all_settings() -> void:
	if not is_inside_tree():
		return

	var selected_res: Vector2i = RESOLUTIONS[
		clampi(resolution_index, 0, RESOLUTIONS.size() - 1)
	]
	var scale := clampf(resolution_scale, 0.25, 1.0)
	var render_size := Vector2i(
		roundi(selected_res.x * scale),
		roundi(selected_res.y * scale)
	)

	var game_vp := get_node_or_null("/root/DisplayRoot/GameViewport") as SubViewport
	if game_vp:
		game_vp.size = render_size

	if FPS_OPTIONS.size() > 0:
		Engine.max_fps = FPS_OPTIONS[
			clampi(fps_limit, 0, FPS_OPTIONS.size() - 1)
		]

	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)

	var window_size := Vector2i(
		roundi(selected_res.x * 0.9),
		roundi(selected_res.y * 0.9)
	)
	DisplayServer.window_set_size(window_size)

	var screen := DisplayServer.window_get_current_screen()
	var usable_rect := DisplayServer.screen_get_usable_rect(screen)
	var position := usable_rect.position + (usable_rect.size - window_size) / 2
	DisplayServer.window_set_position(position)

	_set_bus_volume("Master", master_vol)
	_set_bus_volume("Music", music_vol)
	_set_bus_volume("SFX", sfx_vol)
	_set_bus_volume("Dialog", dialog_vol)

func change_game_scene(scene_path: String) -> void:
	var game_vp := get_node_or_null("/root/DisplayRoot/ScreenContainer/GameViewport") as SubViewport
	if game_vp:
		for child in game_vp.get_children():
			game_vp.remove_child(child)
			child.queue_free()
		var packed := load(scene_path) as PackedScene
		if packed:
			var inst := packed.instantiate()
			game_vp.add_child(inst)
			if inst is Control:
				inst.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	else:
		get_tree().change_scene_to_file(scene_path)

func _set_bus_volume(bus_name: String, linear_val: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx != -1:
		AudioServer.set_bus_volume_db(idx, linear_to_db(clampf(linear_val, 0.0001, 1.0)))
		AudioServer.set_bus_mute(idx, linear_val <= 0.001)

func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("video", "fullscreen", fullscreen)
	cfg.set_value("video", "resolution_index", resolution_index)
	cfg.set_value("video", "resolution_scale", resolution_scale)
	cfg.set_value("video", "fps_limit", fps_limit)
	cfg.set_value("video", "language", language)
	cfg.set_value("video", "effects_enabled", effects_enabled)
	cfg.set_value("video", "colour_mode", colour_mode)
	cfg.set_value("video", "screen_filter", screen_filter)
	cfg.set_value("video", "streamer_mode", streamer_mode)
	cfg.set_value("video", "screen_shake", screen_shake)
	cfg.set_value("video", "flash_reduction", flash_reduction)
	cfg.set_value("controls", "auto_skip_cutscenes", auto_skip_cutscenes)
	cfg.set_value("controls", "show_dialog_boxes", show_dialog_boxes)
	cfg.set_value("controls", "text_speed", text_speed)
	cfg.set_value("controls", "auto_advance_dialog", auto_advance_dialog)
	cfg.set_value("controls", "toggle_block", toggle_block)
	cfg.set_value("sound", "master_vol", master_vol)
	cfg.set_value("sound", "music_vol", music_vol)
	cfg.set_value("sound", "sfx_vol", sfx_vol)
	cfg.set_value("sound", "dialog_vol", dialog_vol)
	cfg.set_value("sound", "mono_audio", mono_audio)
	cfg.set_value("sound", "subtitle_mode", subtitle_mode)
	cfg.set_value("sound", "mute_unfocused", mute_unfocused)
	cfg.set_value("secrets", "unlocked_cheats", unlocked_cheats)
	cfg.save(SAVE_PATH)

func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	fullscreen = cfg.get_value("video", "fullscreen", fullscreen)
	resolution_index = cfg.get_value("video", "resolution_index", resolution_index)
	resolution_scale = cfg.get_value("video", "resolution_scale", resolution_scale)
	fps_limit = cfg.get_value("video", "fps_limit", fps_limit)
	language = cfg.get_value("video", "language", language)
	effects_enabled = cfg.get_value("video", "effects_enabled", effects_enabled)
	colour_mode = cfg.get_value("video", "colour_mode", colour_mode)
	screen_filter = cfg.get_value("video", "screen_filter", screen_filter)
	streamer_mode = cfg.get_value("video", "streamer_mode", streamer_mode)
	screen_shake = cfg.get_value("video", "screen_shake", screen_shake)
	flash_reduction = cfg.get_value("video", "flash_reduction", flash_reduction)
	auto_skip_cutscenes = cfg.get_value("controls", "auto_skip_cutscenes", auto_skip_cutscenes)
	show_dialog_boxes = cfg.get_value("controls", "show_dialog_boxes", show_dialog_boxes)
	text_speed = cfg.get_value("controls", "text_speed", text_speed)
	auto_advance_dialog = cfg.get_value("controls", "auto_advance_dialog", auto_advance_dialog)
	toggle_block = cfg.get_value("controls", "toggle_block", toggle_block)
	master_vol = cfg.get_value("sound", "master_vol", master_vol)
	music_vol = cfg.get_value("sound", "music_vol", music_vol)
	sfx_vol = cfg.get_value("sound", "sfx_vol", sfx_vol)
	dialog_vol = cfg.get_value("sound", "dialog_vol", dialog_vol)
	mono_audio = cfg.get_value("sound", "mono_audio", mono_audio)
	subtitle_mode = cfg.get_value("sound", "subtitle_mode", subtitle_mode)
	mute_unfocused = cfg.get_value("sound", "mute_unfocused", mute_unfocused)
	unlocked_cheats = cfg.get_value("secrets", "unlocked_cheats", unlocked_cheats)
	
func apply_resolution_scale(scale_value: float) -> void:
	if not is_inside_tree():
		return

	resolution_scale = clampf(scale_value, 0.25, 1.0)
	apply_all_settings()

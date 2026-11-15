extends Control

const FIRST_GAME_SCREEN = "res://node_2d.tscn"
const HOLD_TIME = 0.5
const FADE_TIME = 1.0

@onready var main_music = find_child("MainMusic", true, false)
@onready var settings_music = find_child("SettingsMusic", true, false)
@onready var bg_video = $SettingsMenu/BackgroundVideo

var transitioning = false

func _ready() -> void:
	bg_video.expand = true
	bg_video.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _crossfade_music(from: AudioStreamPlayer, to: AudioStreamPlayer) -> void:
	print("CROSSFADE called. from: ", from, "  to: ", to)
	if from == null or to == null:
		push_error("Crossfade skipped: a music node is null. Check the @onready paths.")
		return
	if to.stream == null:
		push_error("Crossfade skipped: ", to.name, " has no Stream assigned.")
		return

	to.volume_db = -40.0
	to.play()
	print("Now playing: ", to.name, "  playing = ", to.playing)

	var tween = create_tween().set_parallel(true)
	tween.tween_property(from, "volume_db", -40.0, FADE_TIME)
	tween.tween_property(to, "volume_db", 0.0, FADE_TIME)
	await tween.finished
	from.stop()
	from.volume_db = 0.0
	to.volume_db = 0.0
	to.play()

func _prepare_settings() -> void:
	# Load saved volume, fill in labels, set slider positions, etc.
	pass

func _on_play_button_pressed() -> void:
	print("PLAY PRESSED: Switching to world...")
	get_tree().change_scene_to_file(FIRST_GAME_SCREEN)

func _on_options_button_pressed() -> void:
	if transitioning:
		return
	transitioning = true

	await $TransitionLayer.cover_screen()

	var hold = get_tree().create_timer(HOLD_TIME)
	_prepare_settings()
	_crossfade_music(main_music, settings_music)
	$Menu_Buttons.hide()
	$SettingsMenu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	$SettingsMenu.show()
	await hold.timeout

	await $TransitionLayer.uncover_screen()
	transitioning = false

func _on_quit_button_pressed() -> void:
	print("QUIT PRESSED: Closing game window. See you later, Donny!")
	get_tree().quit()


extends Control

@onready var screen_tex: TextureRect = $ScreenContainer
@onready var game_vp: SubViewport = $GameViewport

var mouse_inside_game_vp := false

func _ready() -> void:
	screen_tex.texture = game_vp.get_texture()

	game_vp.size_2d_override = Vector2i(1152, 648)
	game_vp.size_2d_override_stretch = true
	game_vp.gui_embed_subwindows = true
	game_vp.handle_input_locally = true

	print("=== VIEWPORT DIAGNOSTIC ===")
	print("GameViewport size: ", game_vp.size)
	print("2D override: ", game_vp.size_2d_override)
	print("2D override stretch: ", game_vp.size_2d_override_stretch)
	print("ScreenContainer size: ", screen_tex.size)
	print("ScreenContainer position: ", screen_tex.position)
	print("===========================")

	game_vp.gui_focus_changed.connect(
		func(control):
			print("VIEWPORT GUI FOCUS: ", control)
	)

func _process(_delta: float) -> void:
	var v_scroll = game_vp.find_child("VideoList", true, false)
	if v_scroll and v_scroll.has_method("get_v_scroll_bar"):
		var bar = v_scroll.get_v_scroll_bar()
		if bar:
			var bar_rect = Rect2(bar.global_position, bar.size)
			var mouse_pos = game_vp.get_mouse_position()

			if bar_rect.has_point(mouse_pos):
				if bar.theme_type_variation != "VScrollBar_Hovered":
					bar.theme_type_variation = "VScrollBar_Hovered"
			else:
				if bar.theme_type_variation == "VScrollBar_Hovered":
					bar.theme_type_variation = ""

func _screen(_delta: float) -> void:
	var video_list := game_vp.find_child("VideoList", true, false) as ScrollContainer

	if video_list == null:
		return

	var bar := video_list.get_v_scroll_bar()

	if bar == null:
		return

	# Always allow the scrollbar to receive mouse input.
	bar.mouse_filter = Control.MOUSE_FILTER_STOP

	# Keep the custom hover appearance.
	var bar_rect := Rect2(bar.global_position, bar.size)
	var mouse_pos := game_vp.get_mouse_position()

	if bar_rect.has_point(mouse_pos):
		if bar.theme_type_variation != "VScrollBar_Hovered":
			bar.theme_type_variation = "VScrollBar_Hovered"
	else:
		if bar.theme_type_variation == "VScrollBar_Hovered":
			bar.theme_type_variation = ""

func _get_drawn_texture_rect() -> Rect2:
	var container_size := screen_tex.size
	var vp_size := Vector2(game_vp.size)

	if vp_size.x <= 0.0 or vp_size.y <= 0.0:
		return Rect2(Vector2.ZERO, container_size)

	var scale_factor := minf(
		container_size.x / vp_size.x,
		container_size.y / vp_size.y
	)
	var drawn_size := vp_size * scale_factor
	var offset := (container_size - drawn_size) * 0.5

	return Rect2(offset, drawn_size)

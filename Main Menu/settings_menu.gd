extends Control

@export var video_bg: Texture2D
@export var controls_bg: Texture2D
@export var sound_bg: Texture2D
@export var unknown_bg: Texture2D

@onready var bg_image: TextureRect = $SettingsMenuImage
@onready var video_control: Control = $VideoControl
@onready var sound_control: Control = $SoundControl
@onready var controls_control: Control = $ControlsControl
@onready var unknown_control: Control = $UnknownControl

@onready var streamer_check: TextureButton = %StreamerCheck
@onready var language_btn: OptionButton = %LanguageBtn
@onready var filter_dropdown: OptionButton = %FilterDropdown
@onready var colour_mode_check: TextureButton = %ColourBlindModeCheck
@onready var flash_check: TextureButton = %FlashCheck
@onready var shake_slider: HSlider = %ShakeSlider
@onready var effects_check: TextureButton = %EffectsCheck
@onready var res_dropdown: OptionButton = %ResDropdown
@onready var res_scale_slider: HSlider = %ResScaleSlider
@onready var fullscreen_check: TextureButton = %FullscreenCheck

func _switch_tab(new_bg: Texture2D, active_control: Control) -> void:
	bg_image.texture = new_bg
	video_control.visible = (active_control == video_control)
	sound_control.visible = (active_control == sound_control)
	controls_control.visible = (active_control == controls_control)
	unknown_control.visible = (active_control == unknown_control)

func _ready() -> void:
	_setup_video_ui()

func _on_res_scale_changed(val: float) -> void:
	SettingsManager.resolution_scale = val / 100.0
	SettingsManager.apply_all_settings()
	SettingsManager.save_settings()

func _on_res_selected(index: int) -> void:
	SettingsManager.resolution_index = index
	SettingsManager.apply_all_settings()
	SettingsManager.save_settings()

func _on_scrollbar_custom_hover() -> void:
	var scroll_container = res_dropdown.get_node("../../..") # Safely targets VideoList (ScrollContainer)
	if scroll_container and scroll_container.has_method("get_v_scroll_bar"):
		var bar = scroll_container.get_v_scroll_bar()
		if bar:
			bar.theme_type_variation = "VScrollBar_Hovered"
			print("Custom Detection System: Hovering scroll zone! Turning grabber red.")

func _on_scrollbar_custom_exit() -> void:
	var scroll_container = res_dropdown.get_node("../../..")
	if scroll_container and scroll_container.has_method("get_v_scroll_bar"):
		var bar = scroll_container.get_v_scroll_bar()
		if bar:
			bar.theme_type_variation = ""
			print("Custom Detection System: Left scroll zone. Resetting grabber texture.")

func _on_scrollbar_custom_leave() -> void:
	var scroll_container = res_dropdown.get_node("../../..") # Safely targets VideoList (ScrollContainer)
	if scroll_container and scroll_container.has_method("get_v_scroll_bar"):
		var bar = scroll_container.get_v_scroll_bar()
		if bar:
			bar.theme_type_variation = ""
			print("Custom Detection System: Left scroll zone. Resetting grabber texture.")

func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if SettingsManager.fullscreen == toggled_on:
		return
	SettingsManager.fullscreen = toggled_on
	SettingsManager.apply_all_settings()
	SettingsManager.save_settings()

func _on_res_list_selected(index: int) -> void:
	SettingsManager.resolution_index = index
	SettingsManager.apply_all_settings()
	SettingsManager.save_settings()

func _on_res_scale_list_changed(val: float) -> void:
	SettingsManager.resolution_scale = val / 100.0
	SettingsManager.apply_all_settings()
	SettingsManager.save_settings()

func _setup_video_ui() -> void:
	res_dropdown.clear()
	for res in SettingsManager.RESOLUTIONS:
		res_dropdown.add_item("%dx%d" % [res.x, res.y])
	
	res_dropdown.selected = SettingsManager.resolution_index
	res_scale_slider.value = SettingsManager.resolution_scale * 100.0
	fullscreen_check.button_pressed = SettingsManager.fullscreen
	effects_check.button_pressed = SettingsManager.effects_enabled
	colour_mode_check.button_pressed = SettingsManager.colour_mode
	filter_dropdown.selected = SettingsManager.screen_filter
	streamer_check.button_pressed = SettingsManager.streamer_mode
	shake_slider.value = SettingsManager.screen_shake * 100.0
	flash_check.button_pressed = SettingsManager.flash_reduction

	if not fullscreen_check.toggled.is_connected(_on_fullscreen_toggled):
		fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	if not res_dropdown.item_selected.is_connected(_on_res_selected):
		res_dropdown.item_selected.connect(_on_res_selected)
	res_scale_slider.value_changed.connect(_on_res_scale_changed)
	effects_check.toggled.connect(func(on: bool): SettingsManager.effects_enabled = on; SettingsManager.save_settings())
	colour_mode_check.toggled.connect(func(on: bool): SettingsManager.colour_mode = on; SettingsManager.save_settings())
	filter_dropdown.item_selected.connect(func(idx: int): SettingsManager.screen_filter = idx; SettingsManager.save_settings())
	streamer_check.toggled.connect(func(on: bool): SettingsManager.streamer_mode = on; SettingsManager.save_settings())
	shake_slider.value_changed.connect(func(val: float): SettingsManager.screen_shake = val / 100.0; SettingsManager.save_settings())
	flash_check.toggled.connect(func(on: bool): SettingsManager.flash_reduction = on; SettingsManager.save_settings())

	# ... (rest of the function remains the same)

func _on_fullscreen_settings_toggled(is_toggled_on: bool) -> void:
	if SettingsManager.fullscreen == is_toggled_on:
		return
	SettingsManager.fullscreen = is_toggled_on
	SettingsManager.apply_all_settings()
	SettingsManager.save_settings()

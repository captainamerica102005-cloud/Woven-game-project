extends Node

@onready var animation_player: AnimationPlayer = $AnimationPlayer # Make sure this matches your AnimationPlayer node name!
var menu_scene_path := "res://Main Menu/main_menu.tscn"

func _ready() -> void:
	# 1. Connect to the animation finished signal automatically
	animation_player.animation_finished.connect(_on_animation_finished)
	
	# 2. Play your boot animation
	animation_player.play("Boot_Animation") # Put your exact animation name here!

func _on_animation_finished(_anim_name: String) -> void:
	# 3. This fires the exact millisecond the animation stops
	transition_to_menu()

func transition_to_menu() -> void:
	var game_vp = get_node_or_null("/root/DisplayRoot/GameViewport") as SubViewport
	
	if game_vp:
		var menu_scene = load(menu_scene_path)
		if menu_scene:
			var menu_instance = menu_scene.instantiate()
			game_vp.add_child(menu_instance)
			queue_free()
	else:
		get_tree().change_scene_to_file(menu_scene_path)

"res://Main Menu/main_menu.tscn"

"res://node_2d.tscn"

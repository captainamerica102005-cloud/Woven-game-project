extends CharacterBody2D

func _ready():
	print("CONNECTION SUCCESSFUL! THE SCRIPT IS WORKING!")

func _physics_process(_delta):
	# Look for our newly created input map action
	if Input.is_action_pressed("move_up"):
		velocity.y = -200
	else:
		velocity.y = 0

	move_and_slide()

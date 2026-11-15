extends CharacterBody2D

func _ready():
	print("CONNECTION SUCCESSFUL! MODULAR LOGIC ENGAGED!")

# 1. This is the ONLY master loop Godot automatically runs
func _physics_process(_delta):
	# We use this master room to call your custom blocks below!
	_physics_up()
	_physics_down()
	_physics_left()
	_physics_right()
	
	# Now that all directions are checked, execute the movement
	move_and_slide()


# 2. Your custom blocks (Notice we removed the "_delta" since the master handles time)
func _physics_up():
	if Input.is_action_pressed("move_up"):
		velocity.y = -500
	else:
		if not Input.is_action_pressed("move_down"): # Only stop if we aren't pressing down
			velocity.y = 0

func _physics_down():
	if Input.is_action_pressed("move_down"):
		velocity.y = 500
	else:
		if not Input.is_action_pressed("move_up"):
			velocity.y = 0

func _physics_left():
	if Input.is_action_pressed("move_left"):
		velocity.x = -500
		$Donny.flip_h = true
	else:
		if not Input.is_action_pressed("move_right"):
			velocity.x = 0

func _physics_right():
	if Input.is_action_pressed("move_right"):
		velocity.x = 500
		$Donny.flip_h = false
	else:
		if not Input.is_action_pressed("move_left"):
			velocity.x = 0

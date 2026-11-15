extends CanvasLayer

const YARN_STAMP_SCENE = preload("res://yarn_stamp.tscn")

@onready var container = $YarnContainer
@onready var pop_on_sound = $PopOnSound
@onready var pop_off_sound = $PopOffSound

# Tweak these to taste
const BALLS_PER_COLUMN = 3.6  # lower = bigger balls
const BALL_DELAY = 0.015      # seconds per ball (higher = slower)

func _play_pop(player: AudioStreamPlayer) -> void:
	player.pitch_scale = randf_range(0.9, 1.1)  # slight variation so it doesn't sound robotic
	player.play()

func cover_screen() -> void:
	var screen = get_viewport().get_visible_rect().size

	var stamp_size = screen.y / BALLS_PER_COLUMN
	var horizontal_spacing = stamp_size * 0.625
	var vertical_spacing = stamp_size * 0.8125

	var columns_needed = int(ceil(screen.x / horizontal_spacing)) + 2
	var rows_needed = int(ceil(screen.y / vertical_spacing)) + 2

	for child in container.get_children():
		child.queue_free()

	for col in range(columns_needed):
		for row in range(rows_needed):
			var stamp = YARN_STAMP_SCENE.instantiate()
			container.add_child(stamp)
			stamp.init_yarn(stamp_size)

			var pos_x = (col - 1) * horizontal_spacing
			var pos_y = (row - 1) * vertical_spacing
			if col % 2 == 1:
				pos_y += vertical_spacing / 2.0

			stamp.position = Vector2(pos_x, pos_y)

			var random_rotations = [0, 90, 180, 270]
			stamp.rotation_degrees = random_rotations[randi() % random_rotations.size()]

			_play_pop(pop_on_sound) 
		

			# One ball at a time
			await get_tree().create_timer(BALL_DELAY).timeout

func uncover_screen() -> void:
	# Remove balls in reverse order of how they appeared
	var stamps = container.get_children()
	stamps.reverse()

	for stamp in stamps:
		stamp.queue_free()
		_play_pop(pop_off_sound)
		await get_tree().create_timer(BALL_DELAY).timeout

extends TextureRect

const TEXTURES = [
	preload("res://Main Menu/Yarn 3.png"), # Green
	preload("res://Main Menu/Yarn 4.png"), # Purple
	preload("res://Main Menu/Yarn 5.png"), # Red
	preload("res://Main Menu/Yarn 1.png"), # Tan
	preload("res://Main Menu/Yarn 2.png")  # Orange
]

func init_yarn(stamp_size: float) -> void:
	texture = TEXTURES[randi() % TEXTURES.size()]
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_SCALE
	custom_minimum_size = Vector2(stamp_size, stamp_size)
	size = Vector2(stamp_size, stamp_size)
	pivot_offset = Vector2(stamp_size / 2.0, stamp_size / 2.0)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

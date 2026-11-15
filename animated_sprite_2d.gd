extends AnimatedSprite2D

const SHEET: Texture2D = preload("res://assets/totally and surelly not claude/forest_menu_sheet.png")  # change path if needed
const COLS := 8
const ROWS := 9
const FRAME_W := 480
const FRAME_H := 270
const FPS := 18.0

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST  # keeps pixels crisp
	z_index = -10                                       # stay behind the title and buttons

	# Fill the screen and center
	var screen := get_viewport_rect().size
	scale = Vector2(screen.x / FRAME_W, screen.y / FRAME_H)
	position = screen / 2.0

	# Build the frames from the sprite sheet
	var frames := SpriteFrames.new()          # already has a "default" animation
	frames.set_animation_speed("default", FPS)
	frames.set_animation_loop("default", true)
	for i in COLS * ROWS:
		var tex := AtlasTexture.new()
		tex.atlas = SHEET
		tex.region = Rect2((i % COLS) * FRAME_W, (i / COLS) * FRAME_H, FRAME_W, FRAME_H)
		frames.add_frame("default", tex)

	sprite_frames = frames
	play("default")

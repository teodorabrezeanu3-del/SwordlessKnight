extends VBoxContainer
## Play / Quit buttons using pixel-art PNG strips.
## Each strip holds 3 frames side by side: normal | hover | pressed (80x28 each).

## Scene that starts the game. Set this in the Inspector.
@export_file("*.tscn") var game_scene: String = "res://game.tscn"

const PLAY_STRIP: Texture2D = preload("res://play_button.png")
const QUIT_STRIP: Texture2D = preload("res://quit_button.png")
const FRAME := Vector2(80, 28)

@onready var play_button: TextureButton = $PlayButton
@onready var quit_button: TextureButton = $QuitButton

func _ready() -> void:
	_setup(play_button, PLAY_STRIP)
	_setup(quit_button, QUIT_STRIP)

	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	if OS.has_feature("web"):      # browsers can't quit
		quit_button.hide()

	play_button.grab_focus()       # keyboard / controller support

	await get_tree().process_frame
	for b: TextureButton in [play_button, quit_button]:
		b.pivot_offset = b.size / 2.0

func _frame(strip: Texture2D, i: int) -> AtlasTexture:
	var t := AtlasTexture.new()
	t.atlas = strip
	t.region = Rect2(Vector2(FRAME.x * i, 0), FRAME)
	return t

func _setup(b: TextureButton, strip: Texture2D) -> void:
	b.texture_normal = _frame(strip, 0)
	b.texture_hover = _frame(strip, 1)
	b.texture_focused = _frame(strip, 1)
	b.texture_pressed = _frame(strip, 2)
	b.mouse_entered.connect(_pop.bind(b, true))
	b.mouse_exited.connect(_pop.bind(b, false))
	b.focus_entered.connect(_pop.bind(b, true))
	b.focus_exited.connect(_pop.bind(b, false))

func _pop(b: TextureButton, up: bool) -> void:
	var tw := create_tween()
	tw.tween_property(b, "scale", Vector2.ONE * (1.05 if up else 1.0), 0.12) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_play_pressed() -> void:
	if ResourceLoader.exists(game_scene):
		get_tree().change_scene_to_file(game_scene)
	else:
		push_warning("Play: game scene not found: %s (set it in the Inspector)" % game_scene)

func _on_quit_pressed() -> void:
	get_tree().quit()

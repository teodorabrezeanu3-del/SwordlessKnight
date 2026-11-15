extends Control

@onready var quit_button: Button = $Quit
@onready var play_button: Button = $Play

func _ready() -> void:
	quit_button.pressed.connect(_on_quit_pressed)
	play_button.pressed.connect(_on_play_pressed)

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_1.tscn")

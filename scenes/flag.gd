extends Area2D

# Change this to your real second level when you have one
@export_file("*.tscn") var next_level := "res://scenes/level_2.tscn"

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if sprite.sprite_frames and sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")


func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D:
		if ResourceLoader.exists(next_level):
			get_tree().call_deferred("change_scene_to_file", next_level)
		else:
			print("Flag reached, but the next level doesn't exist yet: ", next_level)

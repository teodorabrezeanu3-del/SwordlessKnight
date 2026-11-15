extends Area2D

# Velocity given to a bomb that lands on this trampoline (x = push forward, y = up)
@export var bomb_bounce := Vector2(170, -760)
# Upward speed given to the player
@export var player_bounce := 760.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	sprite.animation_finished.connect(func() -> void: _play("idle"))
	_play("idle")


func _play(anim: StringName) -> void:
	if sprite.sprite_frames and sprite.sprite_frames.has_animation(anim):
		sprite.play(anim)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("bomb"):
		body.set_deferred("linear_velocity", bomb_bounce)
		_play("bounce")  # the "bounce" animation must have Loop turned off
	elif body is CharacterBody2D:
		body.velocity.y = -player_bounce
		_play("bounce")

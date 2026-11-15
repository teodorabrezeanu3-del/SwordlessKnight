extends Node2D

@export var bomb_scene: PackedScene
@export var fire_interval := 2.5
@export var launch_velocity := Vector2(300, -450)
@export var spread := 25.0  # random horizontal variation, so the player has to react

@onready var muzzle: Marker2D = $Muzzle
@onready var timer: Timer = $Timer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	timer.wait_time = fire_interval
	timer.timeout.connect(_fire)
	timer.start()
	sprite.animation_finished.connect(func() -> void: _play("idle"))
	_play("idle")


func _play(anim: StringName) -> void:
	if sprite.sprite_frames and sprite.sprite_frames.has_animation(anim):
		sprite.play(anim)


func _fire() -> void:
	_play("shoot")  # the "shoot" animation must have Loop turned off
	var bomb := bomb_scene.instantiate() as RigidBody2D
	get_parent().add_child(bomb)
	bomb.global_position = muzzle.global_position
	bomb.linear_velocity = launch_velocity + Vector2(randf_range(-spread, spread), 0.0)

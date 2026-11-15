extends RigidBody2D

@export var lifetime := 14.0
@export var kick_speed := 380.0
@export var kick_up := 320.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var explosion: AnimatedSprite2D = $Explosion

var exploded := false


func _ready() -> void:
	add_to_group("bomb")
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_on_body_entered)
	$KickArea.body_entered.connect(_on_kick_area_body_entered)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)
	_play_idle()


func _physics_process(_delta: float) -> void:
	# Clean up bombs that fell out of the level
	if global_position.y > 1200.0:
		queue_free()


func _play_idle() -> void:
	if sprite.sprite_frames and sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")


# Bomb touched something solid: any wall makes it explode, breakable walls break too
func _on_body_entered(body: Node) -> void:
	if exploded:
		return
	if body.is_in_group("breakable"):
		body.explode()
	if body.is_in_group("wall"):
		explode()


# Player touched the bomb: ricochet it away from the player
func _on_kick_area_body_entered(body: Node) -> void:
	if exploded:
		return
	if body is CharacterBody2D:
		var dir := signf(global_position.x - body.global_position.x)
		if dir == 0.0:
			dir = 1.0
		linear_velocity = Vector2(dir * kick_speed, -kick_up)


func explode() -> void:
	if exploded:
		return
	exploded = true
	remove_from_group("bomb")  # trampolines and the shield ignore it from now on
	set_deferred("freeze", true)
	$CollisionShape2D.set_deferred("disabled", true)
	$KickArea/CollisionShape2D.set_deferred("disabled", true)
	sprite.hide()
	explosion.show()
	if explosion.sprite_frames and explosion.sprite_frames.has_animation("explode"):
		explosion.play("explode")
		await explosion.animation_finished  # the "explode" animation must have Loop turned off
	queue_free()

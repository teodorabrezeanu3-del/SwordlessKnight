extends CharacterBody2D

signal health_changed(new_health: int)

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const BOUNCE_FORCE = 350.0
const MAX_HEALTH = 3
const SHIELD_OFFSET = 24.0

var bounce_timer := 0.0
var health := MAX_HEALTH
var invincible := false

func _physics_process(delta: float) -> void:
	var shielding := Input.is_action_pressed("shield")
	var facing_left: bool = $AnimatedSprite2D.flip_h
	if shielding:
		$Shield/AnimatedSprite2D.play("shield")
	$Shield.visible = shielding
	$Shield.visible = shielding
	$Shield/CollisionShape2D.set_deferred("disabled", not shielding)
	$Shield.position.x = -SHIELD_OFFSET if facing_left else SHIELD_OFFSET
	$Shield/AnimatedSprite2D.flip_h = facing_left

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("ui_left", "ui_right")
	var final_speed := SPEED
	if Input.is_action_pressed("shift"):
		final_speed = SPEED * 1.5
	if bounce_timer > 0:
		bounce_timer -= delta
	else:
		if direction != 0:
			velocity.x = direction * final_speed
			$AnimatedSprite2D.flip_h = direction < 0
			if Input.is_action_pressed("shift"):
				$AnimatedSprite2D.play("run")
			else:
				$AnimatedSprite2D.play("walk")
		else:
			velocity.x = move_toward(velocity.x, 0, final_speed)
			$AnimatedSprite2D.play("idle")

	move_and_slide()

	# Check what we hit
	if bounce_timer <= 0:
		for i in get_slide_collision_count():
			var collision := get_slide_collision(i)
			var wall := collision.get_collider()
			if wall.is_in_group("bouncy") and abs(collision.get_normal().x) > 0.9:
				velocity.x = collision.get_normal().x * BOUNCE_FORCE
				$AnimatedSprite2D.flip_h = collision.get_normal().x < 0
				velocity.y = -150.0
				bounce_timer = 0.25
				break

func take_damage(amount: int = 1) -> void:
	if invincible:
		return
	health -= amount
	health_changed.emit(health)
	if health <= 0:
		get_tree().reload_current_scene.call_deferred()
		return
	invincible = true
	modulate.a = 0.5
	await get_tree().create_timer(1.0).timeout
	invincible = false
	modulate.a = 1.0

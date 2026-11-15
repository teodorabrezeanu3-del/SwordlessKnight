extends Area2D

const SPEED = 300.0
const LIFETIME = 5.0
const FLOAT_TIME = 0.4    # seconds of straight flight
const CURVE_TIME = 0.1  # seconds for gravity to ramp up to full strength
const GRAVITY_SCALE = 0.5    # 1.0 = same as player gravity

var direction := Vector2.LEFT
var velocity := Vector2.ZERO
var exploding := false
var age := 0.0

func _ready() -> void:
	velocity = direction * SPEED
	$AnimatedSprite2D.play("fireball")
	body_entered.connect(_on_body_entered)
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)
	get_tree().create_timer(LIFETIME).timeout.connect(explode)

func _physics_process(delta: float) -> void:
	if exploding:
		return
	age += delta

	# 0 during the float phase, then ramps smoothly up to 1
	var fall_factor := clampf((age - FLOAT_TIME) / CURVE_TIME, 0.0, 1.0)
	var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
	velocity.y += gravity * GRAVITY_SCALE * fall_factor * delta

	position += velocity * delta
	rotation = velocity.angle()

const DAMAGE = 1

func _on_body_entered(body: Node2D) -> void:
	if exploding:
		return
	if body.is_in_group("player"):
		body.take_damage(DAMAGE)
	explode()
	

func explode() -> void:
	if exploding:
		return
	exploding = true
	rotation = 0
	$AnimatedSprite2D.play("explosion")
	get_tree().create_timer(1.0).timeout.connect(queue_free)

func _on_animation_finished() -> void:
	if exploding:
		queue_free()

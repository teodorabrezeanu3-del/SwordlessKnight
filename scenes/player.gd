extends CharacterBody2D

@export var walk_speed := 180.0
@export var run_speed := 280.0      # hold Shift
@export var sprint_speed := 400.0   # keep Shift held while moving
@export var sprint_delay := 1.0     # seconds of running before the sprint starts
@export var jump_velocity := -430.0
@export var shield_radius := 44.0          # keep equal to the radius of the Shield's CollisionShape2D
@export var shield_bounce_speed := 650.0   # how fast bombs fly off the shield

@onready var shield: Area2D = $Shield
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var shielding := false
var run_time := 0.0


func _ready() -> void:
	add_to_group("player")
	shield.monitoring = false
	shield.body_entered.connect(_on_shield_body_entered)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	# Direction (A, D or arrow keys)
	var dir := 0.0
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		dir -= 1.0
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		dir += 1.0

	# Walk / run / sprint
	var running := Input.is_physical_key_pressed(KEY_SHIFT)
	var speed := 0.0
	var anim := "idle"
	if dir != 0.0:
		if running:
			run_time += delta
		else:
			run_time = 0.0
		if running and run_time >= sprint_delay:
			speed = sprint_speed
			anim = "sprint"
		elif running:
			speed = run_speed
			anim = "run"
		else:
			speed = walk_speed
			anim = "walk"
	else:
		run_time = 0.0
	velocity.x = dir * speed

	# Jump (Space, W or Up)
	var jump_pressed := Input.is_physical_key_pressed(KEY_SPACE) \
			or Input.is_physical_key_pressed(KEY_W) \
			or Input.is_physical_key_pressed(KEY_UP)
	if jump_pressed and is_on_floor():
		velocity.y = jump_velocity

	move_and_slide()
	_update_shield()
	_update_animation(dir, anim)


# Shield is active while the left mouse button is held
func _update_shield() -> void:
	var want := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	if want != shielding:
		shielding = want
		shield.set_deferred("monitoring", shielding)
		queue_redraw()


func _draw() -> void:
	if shielding:
		draw_circle(Vector2.ZERO, shield_radius, Color(0.3, 0.7, 1.0, 0.3))
		draw_arc(Vector2.ZERO, shield_radius, 0.0, TAU, 48, Color(0.5, 0.85, 1.0, 1.0), 3.0)


# A bomb touched the shield: bounce it away from the player
func _on_shield_body_entered(body: Node) -> void:
	if body.is_in_group("bomb"):
		var dir: Vector2 = (body.global_position - global_position).normalized()
		body.set_deferred("linear_velocity", dir * shield_bounce_speed)


func _update_animation(dir: float, anim: String) -> void:
	if dir != 0.0:
		sprite.flip_h = dir < 0.0
	if sprite.sprite_frames == null:
		return
	# Optional "jump" animation while in the air
	if not is_on_floor() and sprite.sprite_frames.has_animation("jump"):
		anim = "jump"
	if sprite.sprite_frames.has_animation(anim) and (sprite.animation != anim or not sprite.is_playing()):
		sprite.play(anim)

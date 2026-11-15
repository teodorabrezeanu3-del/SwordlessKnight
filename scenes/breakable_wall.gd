extends StaticBody2D


func _ready() -> void:
	add_to_group("breakable")
	add_to_group("wall")  # bombs explode on contact with it


# Called by the bomb when it hits this wall
func explode() -> void:
	$CollisionShape2D.set_deferred("disabled", true)
	var tween := create_tween()
	tween.tween_property($Sprite2D, "modulate:a", 0.0, 0.25)
	tween.tween_callback(queue_free)

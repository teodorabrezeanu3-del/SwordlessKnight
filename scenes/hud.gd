extends CanvasLayer

@export var full_heart: Texture2D
@export var empty_heart: Texture2D

@onready var hearts := $HBoxContainer.get_children()

func _ready() -> void:
	await get_tree().process_frame
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		push_error("Player not found in group 'player'")
		return
	player.health_changed.connect(update_hearts)
	update_hearts(player.health)

func update_hearts(health: int) -> void:
	for i in hearts.size():
		hearts[i].texture = full_heart if i < health else empty_heart

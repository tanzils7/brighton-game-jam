extends Area2D

enum PickupType { BLUE, YELLOW, CYAN, PINK }

@export var pickup_type: PickupType = PickupType.BLUE

@export var placeholder1: Texture2D
@export var placeholder2: Texture2D
@export var placeholder3: Texture2D
@export var placeholder4: Texture2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var col: CollisionShape2D = $CollisionShape2D

var is_carried := false
var carrier_point: Node2D = null


func _ready() -> void:
	add_to_group("pickup")
	_apply_visual()


# --- TYPE / VISUALS ---
func set_type(t: int) -> void:
	pickup_type = t
	_apply_visual()

func _apply_visual() -> void:
	if sprite == null:
		return

	match pickup_type:
		PickupType.BLUE:
			sprite.texture = placeholder1
		PickupType.YELLOW:
			sprite.texture = placeholder2
		PickupType.CYAN:
			sprite.texture = placeholder3
		PickupType.PINK:
			sprite.texture = placeholder4


# --- CARRY / DROP ---
func attach_to(point: Node2D) -> void:
	is_carried = true
	carrier_point = point

	# Disable collision while carried
	monitoring = false
	if col != null:
		col.disabled = true

	# Reparent under carry point so it follows automatically
	var old_global := global_position
	get_parent().remove_child(self)
	point.add_child(self)
	global_position = old_global

	# Snap to carry point local position
	position = Vector2.ZERO


func detach(drop_world_pos: Vector2) -> void:
	is_carried = false
	carrier_point = null

	# Reparent back to the main scene
	var old_global := global_position
	var root := get_tree().current_scene
	get_parent().remove_child(self)
	root.add_child(self)
	global_position = old_global

	# Drop at a position you provide (player should calculate forward offset)
	global_position = drop_world_pos + Vector2(35,0)

	# Re-enable collision
	monitoring = true
	if col != null:
		col.disabled = false


# --- PICKUP TRIGGER ---
func _on_body_entered(body: Node2D) -> void:
	if is_carried:
		return
	if body.has_method("try_pickup"):
		body.try_pickup(self)

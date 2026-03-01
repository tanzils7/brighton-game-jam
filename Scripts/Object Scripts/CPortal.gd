extends Area2D

@onready var animation = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation.play("swirl")
	



func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		Global.next_spawn_position = Vector2(200, 150)
		get_tree().change_scene_to_file("res://Scenes/circuits_sub_room.tscn")
		

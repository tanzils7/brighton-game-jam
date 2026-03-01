extends Area2D

@onready var animation = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation.play("swirl")



func _on_body_entered(body: Node2D) -> void:
	print("yay")

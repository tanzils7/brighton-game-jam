extends Area2D

@onready var animation = $AnimatedSprite2D

func _ready() -> void:
	animation.play("swirl")

func _on_body_entered(body: Node2D) -> void:
	print("yay")
	

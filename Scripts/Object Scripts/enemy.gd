extends Area2D


@onready var animation = $AnimatedSprite2D

func _on_body_entered(body: Node2D) -> void:
	queue_free()


func _ready() -> void:
	animation.play("oidle")

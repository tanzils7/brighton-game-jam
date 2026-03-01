extends Area2D

@onready var animation := get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D

func _ready() -> void:
	print("Portal _ready() reached")

	if animation == null:
		push_error("Portal: Could not find child node 'AnimatedSprite2D' (check name/path).")
		return

	if animation.sprite_frames == null:
		push_error("Portal: AnimatedSprite2D has no SpriteFrames resource assigned.")
		return

	if not animation.sprite_frames.has_animation("swirl"):
		push_error("Portal: SpriteFrames does not contain an animation named 'swirl'.")
		print("Available animations: ", animation.sprite_frames.get_animation_names())
		return

	animation.play("swirl")

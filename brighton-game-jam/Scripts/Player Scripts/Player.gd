extends CharacterBody2D

@export var speed: float = 300

func _physics_process(_delta: float) -> void:
	var inputDir: Vector2 = Input.get_vector("Left","Right","Up","Down")
	
	velocity = inputDir * speed
	
	move_and_slide()

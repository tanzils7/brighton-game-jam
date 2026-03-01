extends Area2D

@export var frame_sets: Array[SpriteFrames]

@onready var frames: Array[Sprite2D] = []
@onready var player_inside = false
@onready var correct_p = "down"
@onready var is_correct = false
@onready var is_up = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Interact") and player_inside:
		$PipeH.visible = !$PipeH.visible
		$PipeV.visible = !$PipeV.visible
		print("Helo i work")
		


func _on_area_entered(area: Area2D) -> void:
	player_inside = true
	print("Player is inside")

func _on_area_exited(area: Area2D) -> void:
	player_inside = false
	print("Player is NOT inside")

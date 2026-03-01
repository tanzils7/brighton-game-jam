extends Area2D

signal correct_changed(is_correct: bool)

@onready var player_inside := false
@onready var is_correct := false

func _ready() -> void:
	# Register with manager
	var mgr := get_tree().current_scene.get_node_or_null("PuzzleManager")
	if mgr:
		mgr.register_pipe()
		correct_changed.connect(mgr.pipe_correct_changed)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Interact") and player_inside:
		$PipeH.visible = !$PipeH.visible
		$PipeV.visible = !$PipeV.visible

		# Update correctness after toggle
		_update_correctness()

func _update_correctness() -> void:
	# Example: vertical = correct (you can replace this with your real logic)
	var now_correct := $PipeV.visible

	if now_correct != is_correct:
		is_correct = now_correct
		correct_changed.emit(is_correct)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		player_inside = true

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("player"):
		player_inside = false

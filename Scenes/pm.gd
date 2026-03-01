extends Node

@export var next_scene: String = "res://Scenes/main.tscn"


var correct_count := 0
var total := 6

func register_pipe() -> void:
	total += 1

func pipe_correct_changed(is_correct: bool) -> void:
	# We'll get +1 when a pipe becomes correct, -1 when it becomes incorrect
	correct_count += (1 if is_correct else -1)
	print("Correct:", correct_count, "/", total)

	if correct_count == total:
		get_tree().change_scene_to_file(next_scene)

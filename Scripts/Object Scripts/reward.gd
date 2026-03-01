extends Area2D

@export var main_scene: String = "res://Scenes/main.tscn"
@export var return_spawn: NodePath

func _on_body_entered(body: Node2D) -> void:
	Global.reward_collected["FETCH_REWARD"] = true

	var sp := get_node_or_null(return_spawn)
	if sp != null:
		Global.next_spawn_position = sp.global_position

	get_tree().change_scene_to_file(main_scene)

extends Node2D

@export var reward_scene: PackedScene
@export var reward_spawn_point: NodePath        # drag RewardSpawn Marker2D
@export var main_scene: String = "res://MainLevel.tscn"
@export var return_spawn_in_main: NodePath      # drag ReturnSpawnInMain Marker2D (in THIS quest scene)

var reward_spawned := false


func _ready() -> void:
	add_to_group("zone_manager")

	# Reset zone progress when entering this quest level
	Global.zone_done = {
		"BLUE": false,
		"YELLOW": false,
		"CYAN": false,
		"PINK": false
	}
	reward_spawned = false


func check_all_zones() -> void:
	for key in Global.zone_done.keys():
		if Global.zone_done[key] == false:
			return

	if not reward_spawned:
		_spawn_reward()
		reward_spawned = true
	_return_to_main()


func _spawn_reward() -> void:
	if reward_scene == null:
		return
	var sp := get_node_or_null(reward_spawn_point)
	if sp == null:
		return

	var reward := reward_scene.instantiate() as Node2D
	get_tree().current_scene.add_child(reward)
	reward.global_position = sp.global_position


func _return_to_main() -> void:
	# Set where player will spawn in main (optional)
	var rs := get_node_or_null(return_spawn_in_main)
	if rs != null:
		Global.next_spawn_position = rs.global_position
	else:
		Global.next_spawn_position = Vector2.ZERO

	get_tree().change_scene_to_file(main_scene)

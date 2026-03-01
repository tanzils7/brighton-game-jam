extends Node2D

@export var reward_scene: PackedScene
@export var reward_id: String = "FETCH_REWARD"
@export var spawn_point: NodePath  # drag RewardSpawn marker here

var spawned := false

func try_spawn_reward() -> void:
	# Don't spawn if already collected
	if Global.reward_collected.get(reward_id, false):
		return

	# Don't spawn twice in this scene
	if spawned:
		return

	# Only spawn if all zones are complete
	for key in Global.zone_done.keys():
		if Global.zone_done[key] == false:
			return

	var sp := get_node_or_null(spawn_point)
	if sp == null or reward_scene == null:
		return

	var r := reward_scene.instantiate() as Node2D
	get_tree().current_scene.add_child(r)
	r.global_position = sp.global_position
	spawned = true

func _ready() -> void:
	add_to_group("reward_spawner")

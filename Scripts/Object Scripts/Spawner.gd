extends Node2D

@export var pickup_scene: PackedScene
@export var count_per_type: int = 4          # 4 of each
@export var number_of_types: int = 4         # RED/BLUE/GREEN/YELLOW

@export var spawn_interval: float = 0.25
@export var min_distance: float = 32.0
@export var max_attempts: int = 60

@onready var top_left: Marker2D = $SpawnTopLeft
@onready var bottom_right: Marker2D = $SpawnBottomRight

var _spawn_rect: Rect2
var _spawn_queue: Array[int] = []            # holds type ids to spawn
var _spawned_positions: Array[Vector2] = []
var _accum := 0.0

func _ready() -> void:
	randomize()

	if pickup_scene == null:
		push_error("Spawner: pickup_scene not assigned.")
		return

	_spawn_rect = _get_spawn_rect()
	if _spawn_rect.size.x <= 1.0 or _spawn_rect.size.y <= 1.0:
		push_error("Spawner: spawn rect too small, move the markers apart.")
		return

	_build_spawn_queue()
	print("Spawn queue size:", _spawn_queue.size()) # should be 16

func _process(delta: float) -> void:
	if _spawn_queue.is_empty():
		return

	_accum += delta
	if _accum >= spawn_interval:
		_accum -= spawn_interval
		_try_spawn_one()

func _build_spawn_queue() -> void:
	_spawn_queue.clear()
	for t in range(number_of_types):           # 0..3
		for i in range(count_per_type):        # 4 each
			_spawn_queue.append(t)
	_spawn_queue.shuffle()

func _try_spawn_one() -> void:
	var type_id := _spawn_queue[0]

	for attempt in range(max_attempts):
		var candidate := _random_point_in(_spawn_rect)
		if _is_far_enough(candidate):
			var p := pickup_scene.instantiate() as Area2D
			get_tree().current_scene.add_child(p)
			p.global_position = candidate

			# Tell the pickup which type it is
			p.call("set_type", type_id)

			_spawned_positions.append(candidate)
			_spawn_queue.pop_front()
			return

	# If it can't find room this tick, it will try again next interval.

func _is_far_enough(pos: Vector2) -> bool:
	for prev in _spawned_positions:
		if pos.distance_to(prev) < min_distance:
			return false
	return true

func _get_spawn_rect() -> Rect2:
	var a := top_left.global_position
	var b := bottom_right.global_position

	var x1: float = min(a.x, b.x)
	var y1: float = min(a.y, b.y)
	var x2: float = max(a.x, b.x)
	var y2: float = max(a.y, b.y)

	return Rect2(Vector2(x1, y1), Vector2(x2 - x1, y2 - y1))

func _random_point_in(rect: Rect2) -> Vector2:
	return Vector2(
		randf_range(rect.position.x, rect.position.x + rect.size.x),
		randf_range(rect.position.y, rect.position.y + rect.size.y)
	)

extends Area2D

@export var zone_key: String = "BLUE"   # set per zone: BLUE/YELLOW/CYAN/PINK
@export var required_count: int = 4

var inside: Array[Area2D] = []
var completed := false


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func _on_area_entered(a: Area2D) -> void:
	if completed:
		return
	if not a.is_in_group("pickup"):
		return
	if a not in inside:
		inside.append(a)
	_check_exact()


func _on_area_exited(a: Area2D) -> void:
	if a in inside:
		inside.erase(a)


func _check_exact() -> void:
	# exactly 4 means: trigger only when size == 4
	if inside.size() == required_count:
		_complete()


func _complete() -> void:
	completed = true
	Global.zone_done[zone_key] = true

	# consume exactly these 4
	for p in inside:
		if is_instance_valid(p):
			p.queue_free()

	# tell manager to check if all zones are done
	get_tree().call_group("zone_manager", "check_all_zones")

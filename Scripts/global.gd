extends Node

var next_spawn_position: Vector2 = Vector2.ZERO
var spawn_name: String = ""

# completion for each zone (use keys like "BLUE", "YELLOW", "CYAN", "PINK")
var zone_done := {
	"BLUE": false,
	"YELLOW": false,
	"CYAN": false,
	"PINK": false
}

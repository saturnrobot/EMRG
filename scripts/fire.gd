extends Node2D
class_name Fire

var intensity: float = 1.0
var spread_timer: Timer
var is_large: bool = false
var discovered: bool = false

func _ready() -> void:
	add_to_group("fires")
	spread_timer = $SpreadTimer
	spread_timer.start()

func initialize(large: bool) -> void:
	is_large = large
	if large:
		scale *= 4.0
		intensity = 100.0

func discover() -> void:
	if not discovered:
		discovered = true
		var score_manager = get_tree().get_first_node_in_group("score_manager")
		if score_manager:
			score_manager.record_action("fire_discovered", true)

func extinguish() -> void:
	if is_large:
		return
	intensity -= 0.1
	if intensity <= 0:
		var score_manager = get_tree().get_first_node_in_group("score_manager")
		if score_manager:
			score_manager.record_action("fire_extinguished", true)
			score_manager.display_score()
		queue_free()

func _on_spread_timer_timeout() -> void:
	if intensity < 1.5:
		intensity += 0.1
		self.scale *= 1.1
	else:
		is_large = true
		spread_timer.stop()

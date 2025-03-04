extends Node

var current_score: int = 100
var time_started: float
var actions_performed: Dictionary = {}

func _ready() -> void:
	time_started = Time.get_ticks_msec()

func record_action(action: String, success: bool) -> void:
	actions_performed[action] = success

	match action:
		"activated_alarm":
			if success: current_score += 20
		"helped_others":
			if success: current_score += 15
		"used_extinguisher":
			if success: current_score += 10
		"closed_doors":
			if success: current_score += 10
		"used_elevator":
			current_score -= 50

func calculate_final_score() -> int:
	var time_taken = (Time.get_ticks_msec() - time_started) / 1000.0
	if time_taken > 300: # 5 minutes
		current_score -= 20
	return current_score

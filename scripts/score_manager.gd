extends Node

var current_score: int = 0
var time_started: float
var actions_performed: Array = [] 
var is_large_fire: bool = false

const POINTS = {
	"fire_discovered": 15,
	"activated_alarm": 20,
	"fire_extinguished": 30,
	"exited_building": 10,
	"fire_extinguisher_grabbed": 0
}

const ORDER_BONUS = 25

func _ready() -> void:
	time_started = Time.get_ticks_msec()
	add_to_group("score_manager")

func set_fire_size(is_large: bool) -> void:
	is_large_fire = is_large

func record_action(action: String, success: bool) -> void:
	if not success or actions_performed.has(action):
		return 
		
	actions_performed.append(action)
	add_base_points(action)
	check_order_bonus()

func add_base_points(action: String) -> void:
	if action in POINTS:
		current_score += POINTS[action]
		print("Added %d points for %s" % [POINTS[action], action])

func check_order_bonus() -> void:
	if is_large_fire:
		check_large_fire_order()
	else:
		check_small_fire_order()

func check_large_fire_order() -> void:
	var correct_order = ["fire_discovered", "activated_alarm", "exited_building"]
	check_sequence(correct_order)

func check_small_fire_order() -> void:
	var correct_order = ["fire_discovered", "fire_extinguisher_grabbed", "fire_extinguished"]
	check_sequence(correct_order)

func check_sequence(correct_order: Array) -> void:
	var current_sequence = []
	var bonus_given = false
	
	for action in actions_performed:
		if action == "activated_alarm" && not is_large_fire:
			current_score -= 15
		if action in correct_order:
			current_sequence.append(action)
	
	if current_sequence.size() == correct_order.size():
		var sequence_correct = true
		for i in range(current_sequence.size()):
			if current_sequence[i] != correct_order[i]:
				sequence_correct = false
				break
		
		if sequence_correct and not bonus_given:
			current_score += ORDER_BONUS
			print("Added %d bonus points for correct order!" % ORDER_BONUS)
			bonus_given = true

func calculate_final_score() -> int:
	var time_taken = (Time.get_ticks_msec() - time_started) / 1000.0
	if time_taken > 300:
		current_score -= 20
		print("Subtracted 20 points for taking too long")
	return current_score

func display_score() -> void:
	var final_score = calculate_final_score()
	print("\nFinal Score Breakdown:")
	print("Actions performed in order:", actions_performed)
	print("Final Score:", final_score)
	if is_large_fire:
		print("This was a large fire scenario")
		print("Optimal sequence: Discover Fire -> Activate Alarm -> Exit Building")
	else:
		print("This was a small fire scenario")
		print("Optimal sequence: Discover Fire -> Grab Extinguisher -> Extinguish Fire")
	get_tree().paused = true

extends Node

var current_score: int = 0
var total_score: int = 0
var current_level: int = 1
var total_levels: int = 2
var time_started: float
var actions_performed: Array = [] 
var is_large_fire: bool = false

@onready var score_display = $ScoreDisplay
@onready var actions_display = $ActionsDisplay
@onready var scenario_display = $ScenarioDisplay
@onready var optimal_sequence_display = $OptimalSequenceDisplay
@onready var time_display = $TimeDisplay
@onready var restart_prompt = $RestartPrompt

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
	hide_ui_elements()

func hide_ui_elements() -> void:
	score_display.hide()
	actions_display.hide()
	scenario_display.hide()
	optimal_sequence_display.hide()
	restart_prompt.hide()
	time_display.hide()

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
		update_score_display()

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
			bonus_given = true

func calculate_final_score() -> int:
	var time_taken = (Time.get_ticks_msec() - time_started) / 1000.0
	if time_taken > 300:
		current_score -= 20
	return current_score

func update_score_display() -> void:
	score_display.text = "Score: %d" % current_score

func display_score() -> void:
	var final_score = calculate_final_score()
	
	score_display.show()
	actions_display.show()
	scenario_display.show()
	optimal_sequence_display.show()
	restart_prompt.show()
	time_display.show()
	
	score_display.text = "Final Score: %d" % final_score
	actions_display.text = "Actions Performed:\n" + "\n".join(actions_performed)
	
	time_display.text = "Time: " + str((Time.get_ticks_msec() - time_started) / 1000.0)
	
	if is_large_fire:
		scenario_display.text = "LARGE FIRE SCENARIO"
		optimal_sequence_display.text = "Optimal Response:\n1. Discover Fire\n2. Activate Alarm\n3. Exit Building Immediately"
	else:
		scenario_display.text = "SMALL FIRE SCENARIO"
		optimal_sequence_display.text = "Optimal Response:\n1. Discover Fire\n2. Grab Fire Extinguisher\n3. Extinguish Fire"
	
	#restart_prompt.text = "Press R to Restart"
	
	if current_level == total_levels:
		restart_prompt.text = "Press R to Restart\nPress Esc to Exit"
	else:
		restart_prompt.text = "Press R to Restart\nPress N for Next Level"
	
	get_tree().paused = true

func reset_for_new_level() -> void:
	total_score += current_score
	
	current_score = 0
	time_started = Time.get_ticks_msec()
	actions_performed.clear()
	
	update_score_display()
	hide_ui_elements()

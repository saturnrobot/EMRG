extends Node2D

@onready var player = get_node("../Player")
@onready var house_scene = get_node("../House")
@onready var library_scene = get_node("../Library")
@onready var main = get_node("../../Main")
@onready var score_manager = get_tree().get_first_node_in_group("score_manager")
@onready var alarm = get_node("../Alarm/Fire Alarm")
@onready var extinguisher = get_node("../Extinguisher")

func _process(_delta: float) -> void:
	if get_tree().paused and Input.is_action_just_pressed("restart"):
		get_tree().paused = false
		load_level(0)
	elif get_tree().paused and Input.is_action_just_pressed("continue") and score_manager.current_level < score_manager.total_levels:
		get_tree().paused = false
		load_level(1)
	elif get_tree().paused and Input.is_action_just_pressed("exit_game") and score_manager.current_level == score_manager.total_levels:
		get_tree().quit()
		
func load_level(is_loading_same_level: int) -> void:
	if score_manager:
		score_manager.current_level += is_loading_same_level
		
		# Reset the score and timer for the new level
		score_manager.reset_for_new_level()
	
		# Hide the house scene & reveal library
		if score_manager.current_level == 1:
			get_tree().reload_current_scene()
		elif score_manager.current_level == 2:
			extinguisher.get_node("Extinguisher Sound").playing = false
			for fire in get_tree().get_nodes_in_group("fires"):
				fire.queue_free()
			
			house_scene.visible = false
			library_scene.visible = true
			
			# Reset fires and reposition interactables
			if main:
				main.reset_fires()
				main.reposition_interactables()
				main.spawn_initial_fire()
			
			reset_player_position(score_manager.current_level)
		else:
			print("No more levels available.")
			get_tree().paused = false
			return


func reset_player_position(level: int) -> void:
	if player:
		if level == 1:
			player.global_position = Vector2(0, -78)
		elif level == 2:
			player.global_position = Vector2(-30, 118)
		
		if player.is_holding_item:
			player.drop_item()

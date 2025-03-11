extends Node2D

@onready var player = get_node("../Player")
@onready var house_scene = get_node("../House")
@onready var library_scene = get_node("../Library")
@onready var main = get_node("../../Main")
@onready var score_manager = get_tree().get_first_node_in_group("score_manager")

# Position far away to hide the library
const FAR_AWAY_POSITION = Vector2(10000, 10000)

func _ready() -> void:
	# Move library scene far away at start
	if library_scene:
		library_scene.position = FAR_AWAY_POSITION

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
		
		# Stop all sounds
		if main:
			main.stop_all_sounds()
		
		# Reset the timer overlay
		var timer_overlay = get_tree().get_first_node_in_group("timer_overlay")
		if timer_overlay:
			timer_overlay.reset()
	
		# Handle scene transitions
		if score_manager.current_level == 1:
			get_tree().reload_current_scene()
		elif score_manager.current_level == 2:
			for fire in get_tree().get_nodes_in_group("fires"):
				fire.queue_free()
			
			# Move house scene far away
			house_scene.position = FAR_AWAY_POSITION
			
			# Move library scene to origin
			library_scene.position = Vector2.ZERO
			
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

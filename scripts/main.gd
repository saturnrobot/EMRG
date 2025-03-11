extends Node2D
class_name Main

@export var fire_scene: PackedScene
@export var possible_fire_locations: Array[NodePath]
@export var extinguisher_locations: Array
@export var alarm_locations: Array
@export var fire_spawner_locations: Array
@export var exit_locations: Array
@export var time_to_fire: float = 5.0
var fire_locations

var current_time: float = 0.0
var fire: bool = false
var is_large_fire: bool = false

@onready var score_manager = $ScoreManager
@onready var player = $Player
@onready var controls_button = $ControlsButton
@onready var controls_panel = $ControlsPanel


func _ready() -> void:
	score_manager.add_to_group("score_manager")
	controls_panel.hide()

	alarm_locations.append(Vector2(149,-107))
	alarm_locations.append(Vector2(-132,72))
	extinguisher_locations.append(Vector2(-15, -218))
	extinguisher_locations.append(Vector2(-310, 494))
	exit_locations.append(Vector2(158, 258))
	exit_locations.append(Vector2(-31, 815))

	# 1st lvl fire spawns
	fire_spawner_locations.append(Vector2(-201, -191))
	fire_spawner_locations.append(Vector2(-520, -177))

	# 2nd lvl fire spawns
	fire_spawner_locations.append(Vector2(484, 120))
	fire_spawner_locations.append(Vector2(422, 626))
	#fire_spawner_locations.append(Vector2(-554, 198))
	#possible_fire_locations.append(Node2D(Vector2(-201, -191)))


func _on_alarm_alarm_activated() -> void:
	score_manager.record_action("activated_alarm", true)
	$Alarm/AlarmShader.visible = true
func spawn_initial_fire() -> void:

	is_large_fire = randf() > 0.5
	score_manager.set_fire_size(is_large_fire)

	# Original Fire Spawning Code
	#var random_location_path = possible_fire_locations[randi() % possible_fire_locations.size()]
	#var spawn_point = get_node(random_location_path)
	#
	#var fire_instance = fire_scene.instantiate()
	#add_child(fire_instance)
	#fire_instance.global_position = spawn_point.global_position
	#fire_instance.initialize(is_large_fire)


	var spawn_point = Node2D.new()
	add_child(spawn_point)

	if score_manager.current_level == 1:
		var index = randi() % 2
		spawn_point.global_position = fire_spawner_locations[index]
	elif score_manager.current_level == 2:
		var index = 2 + randi() % 2  # Use indices 2 and 3
		spawn_point.global_position = fire_spawner_locations[index]

	# Create the fire instance
	var fire_instance = fire_scene.instantiate()
	add_child(fire_instance)
	fire_instance.global_position = spawn_point.global_position
	fire_instance.initialize(is_large_fire)
	spawn_point.queue_free()

func _on_exit_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		score_manager.record_action("exited_building", true)
		score_manager.display_score()

func _process(delta: float) -> void:
	current_time+=delta
	if (current_time > time_to_fire and not fire):
		get_node("Background Music").stop()
		get_node("Fire Music").play()
		fire = true
		for existing_fire in get_tree().get_nodes_in_group("fires"):
			existing_fire.queue_free()
		spawn_initial_fire()

func _on_controls_button_pressed() -> void:
	controls_panel.visible = !controls_panel.visible

func reset_fires() -> void:
	for fire in get_tree().get_nodes_in_group("fires"):
		fire.queue_free()

	current_time = 0.0
	fire = false

	var cur_fire
	if score_manager.current_level == 1:
		cur_fire = get_node(possible_fire_locations[0]).global_position
		cur_fire.global_position = fire_spawner_locations[0]
		cur_fire = get_node(possible_fire_locations[1]).global_position
		cur_fire.global_position = fire_spawner_locations[1]
	elif score_manager.current_level == 1:
		cur_fire = get_node(possible_fire_locations[2]).global_position
		cur_fire.global_position = fire_spawner_locations[2]
		cur_fire = get_node(possible_fire_locations[3]).global_position
		cur_fire.global_position = fire_spawner_locations[3]

func reposition_interactables() -> void:
	var extinguisher = get_node("Extinguisher")
	var alarm = get_node("Alarm")
	var exit = get_node("Exit")

	if score_manager.current_level == 1:
		alarm.global_position = alarm_locations[0]
		extinguisher.global_position = extinguisher_locations[0]
		exit.global_position = exit_locations[0]
	elif score_manager.current_level == 2:
		alarm.global_position = alarm_locations[1]
		extinguisher.global_position = extinguisher_locations[1]
		exit.global_position = exit_locations[1]

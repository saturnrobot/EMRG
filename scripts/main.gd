extends Node2D
class_name Main

@export var fire_scene: PackedScene
@export var possible_fire_locations: Array[NodePath]
@export var time_to_fire: float = 5.0

var current_time: float = 0.0
var fire: bool = false

@onready var score_manager = $ScoreManager
@onready var player = $Player

func _ready() -> void:
	connect_signals()

func connect_signals() -> void:
	for alarm in get_tree().get_nodes_in_group("fire_alarms"):
		alarm.alarm_activated.connect(_on_alarm_activated)

func _on_alarm_activated() -> void:
	score_manager.record_action("activated_alarm", true)

func spawn_initial_fire() -> void:
	if fire_scene == null:
		push_error("Fire scene not set!")
		return
		
	if possible_fire_locations.is_empty():
		push_error("No fire spawn locations set!")
		return
		
	var random_location_path = possible_fire_locations[randi() % possible_fire_locations.size()]
	var spawn_point = get_node(random_location_path)
	
	if spawn_point == null:
		push_error("Invalid spawn point!")
		return
		
	var fire = fire_scene.instantiate()
	add_child(fire)
	fire.global_position = spawn_point.global_position

func _process(delta: float) -> void:
	current_time+=delta
	if (current_time > time_to_fire and not fire):
		get_node("Background Music").stop()
		get_node("Fire Music").play()
		fire = true
		spawn_initial_fire()

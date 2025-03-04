extends Node2D
class_name Main

@export var fire_scene: PackedScene
@export var possible_fire_locations: Array[NodePath]
@export var time_to_fire: float = 5.0

var current_time: float = 0.0
var fire: bool = false
var is_large_fire: bool = false

@onready var score_manager = $ScoreManager
@onready var player = $Player

func _ready() -> void:
	score_manager.add_to_group("score_manager")

func _on_alarm_alarm_activated() -> void:
	score_manager.record_action("activated_alarm", true)

func spawn_initial_fire() -> void:
	is_large_fire = randf() > 0.5
	score_manager.set_fire_size(is_large_fire)
	
	var random_location_path = possible_fire_locations[randi() % possible_fire_locations.size()]
	var spawn_point = get_node(random_location_path)
	
	var fire_instance = fire_scene.instantiate()
	add_child(fire_instance)
	fire_instance.global_position = spawn_point.global_position
	fire_instance.initialize(is_large_fire)

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
		spawn_initial_fire()

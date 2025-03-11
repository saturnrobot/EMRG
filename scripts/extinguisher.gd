extends RigidBody2D
class_name FireExtinguisher

var held: bool = false
var activated: bool = false
var spray_particles: CPUParticles2D
var spray_area: Area2D
@export var offset_distance: float = 20.0
@export var max_fuel: float = 100.0
var current_fuel: float = max_fuel
@export var fuel_usage_rate: float = 10.0

func _ready() -> void:
	add_to_group("extinguishers")
	spray_particles = $SprayParticles
	spray_area = $SprayArea
	spray_particles.emitting = false
	current_fuel = max_fuel

func _physics_process(_delta: float) -> void:
	if held and is_instance_valid(holding_player):
		var offset = Vector2.RIGHT.rotated(holding_player.sprite.rotation) * offset_distance
		global_position = holding_player.global_position + offset
		rotation = holding_player.sprite.rotation

var holding_player: PlayerController = null

func on_pickup(player: PlayerController) -> void:
	held = true
	holding_player = player
	collision_layer = 0
	collision_mask = 0
	freeze = true
	var score_manager = get_tree().get_first_node_in_group("score_manager")
	if score_manager:
		score_manager.record_action("fire_extinguisher_grabbed", true)

func on_drop(_player: PlayerController) -> void:
	held = false
	holding_player = null
	collision_layer = 1
	collision_mask = 1
	spray_particles.emitting = false

func activate() -> void:
	if held and current_fuel > 0:
		spray_particles.emitting = true
		if not activated:
			get_node("Extinguisher Sound").playing = true
			activated = true
		check_fire_collision()
	elif current_fuel <= 0:
		deactivate()

func deactivate() -> void:
	spray_particles.emitting = false
	get_node("Extinguisher Sound").playing = false
	activated = false

func check_fire_collision() -> void:
	var bodies = spray_area.get_overlapping_bodies()
	for body in bodies:
		if body is Fire:
			body.extinguish()

func _process(delta: float) -> void:
	if spray_particles.emitting and current_fuel > 0:
		current_fuel -= fuel_usage_rate * delta
		if current_fuel <= 0:
			current_fuel = 0
			deactivate()

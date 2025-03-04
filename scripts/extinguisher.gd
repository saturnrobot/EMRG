extends RigidBody2D
class_name FireExtinguisher

var held: bool = false
var spray_particles: CPUParticles2D
var spray_area: Area2D

func _ready() -> void:
	spray_particles = $SprayParticles
	spray_area = $SprayArea
	spray_particles.emitting = false

func on_pickup(player: PlayerController) -> void:
	held = true
	collision_layer = 0
	collision_mask = 0
	global_position = player.global_position

func on_drop(player: PlayerController) -> void:
	held = false
	collision_layer = 1
	collision_mask = 1

func aim(direction: Vector2) -> void:
	rotation = direction.angle()
	if Input.is_action_pressed("use_item"):
		spray_particles.emitting = true
		check_fire_collision()
	else:
		spray_particles.emitting = false

func check_fire_collision() -> void:
	var bodies = spray_area.get_overlapping_bodies()
	for body in bodies:
		if body is Fire:
			body.extinguish()

extends RigidBody2D
class_name Box

var held: bool = false

func on_pickup(player: PlayerController) -> void:
	held = true
	collision_layer = 0
	collision_mask = 0
	global_position = player.global_position

func on_drop(player: PlayerController) -> void:
	held = false
	collision_layer = 1
	collision_mask = 1

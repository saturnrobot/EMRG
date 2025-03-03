extends Node

class_name Main

@export var time_to_fire: float = 10.0
var current_time: float = 0.0
var fire: bool = false

func _process(delta: float) -> void:
	current_time+=delta
	if (current_time > time_to_fire and not fire):
		get_node("Background Music").stop()
		get_node("Fire Music").play()
		fire = true

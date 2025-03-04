extends Node2D

func _process(_delta: float) -> void:
	if get_tree().paused and Input.is_action_just_pressed("restart"):
		get_tree().paused = false 
		get_tree().reload_current_scene()

extends Node2D
class_name Interactable

signal interaction_completed(success: bool)

func interact(actor: Node2D) -> void:
	pass

func can_interact() -> bool:
	return true

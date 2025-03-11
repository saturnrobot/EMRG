extends Interactable

var activated: bool = false
signal alarm_activated

func interact(_actor: Node2D) -> void:
	if not activated:
		activated = true
		get_node("Fire Alarm").play()
		emit_signal("alarm_activated")

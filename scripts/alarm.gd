extends Interactable

var activated: bool = false
signal alarm_activated

func interact(actor: Node2D) -> void:
	if not activated:
		activated = true
		$AlarmSound.play()
		emit_signal("alarm_activated")
		emit_signal("interaction_completed", true)

extends Interactable

var activated: bool = false
signal alarm_activated

func _ready() -> void:
	add_to_group("alarms")

func interact(_actor: Node2D) -> void:
	if not activated:
		activated = true
		get_node("Fire Alarm").play()
		emit_signal("alarm_activated")

func OFF () -> void:
	activated = false

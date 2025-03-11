extends CanvasLayer

@export var max_time: float = 60.0
var current_time: float = 0.0
var time_percent: float = 0.0
var timer_active: bool = false

@onready var timer_label = $TimerLabel
@onready var flame_overlay = $FlameOverlay

func _ready() -> void:
	add_to_group("timer_overlay")
	timer_label.visible = false
	flame_overlay.visible = false
	flame_overlay.modulate = Color(1, 0.5, 0, 0.0) 

func _process(delta: float) -> void:
	if get_tree().paused or not timer_active:
		return
		
	current_time += delta
	time_percent = current_time / max_time
	
	var minutes = floor(current_time / 60)
	var seconds = int(floor(current_time)) % 60
	var milliseconds = floor((current_time - floor(current_time)) * 100)
	timer_label.text = "%d:%02d.%02d" % [minutes, seconds, milliseconds]
	
	flame_overlay.modulate = Color(1, 0.5, 0, min(0.8 * time_percent, 0.8))
	
	if current_time >= max_time:
		var score_manager = get_tree().get_first_node_in_group("score_manager")
		if score_manager:
			score_manager.time_expired()

func reset() -> void:
	current_time = 0.0
	timer_active = false
	timer_label.visible = false
	flame_overlay.visible = false
	flame_overlay.modulate = Color(1, 0.5, 0, 0.0)
	
func start_timer() -> void:
	current_time = 0.0
	timer_active = true
	timer_label.visible = true
	flame_overlay.visible = true

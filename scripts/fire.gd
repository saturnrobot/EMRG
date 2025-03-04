extends Node2D
class_name Fire

var intensity: float = 1.0
var smoke_particles: CPUParticles2D
var fire_particles: CPUParticles2D
var spread_timer: Timer

func _ready() -> void:
	smoke_particles = $SmokeParticles
	fire_particles = $FireParticles
	spread_timer = $SpreadTimer
	spread_timer.start()

func extinguish() -> void:
	intensity -= 0.1
	if intensity <= 0:
		queue_free()

func _on_spread_timer_timeout() -> void:
	if intensity < 1.5:
		intensity += 0.1

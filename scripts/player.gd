extends CharacterBody2D
class_name PlayerController

@export var max_speed: float = 300.0
@export var acceleration: float = 2000.0
@export var friction: float = 1000.0
@export var rotation_speed: float = 10.0
@export var fire_detection_distance: float = 100.0

var input_vector: Vector2 = Vector2.ZERO
var current_velocity: Vector2 = Vector2.ZERO
var is_holding_item: bool = false
var held_item = null
var damage_dealt;
var damage_start = true;

@onready var sprite: Sprite2D = $PlayerSprite
@onready var interaction_area: Area2D = $InteractionArea
@onready var health_bar = $HealthBar
@onready var health_bar_timer = $HealthBarTimer
@onready var exclamation: Sprite2D = $Exclamation

func _ready() -> void:
	$PlayerAnimation.play("idle")

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	handle_interaction()
	handle_item_activation()
	check_fire_proximity()

func handle_item_activation() -> void:
	if is_holding_item:
		if Input.is_action_pressed("activate"):
			if held_item.has_method("activate"):
				held_item.activate()
		elif Input.is_action_just_released("activate"):
			if held_item.has_method("deactivate"):
				held_item.deactivate()

func handle_interaction() -> void:
	if Input.is_action_just_pressed("interact"):
		var interactables = get_interactables_in_range()
		if !is_holding_item and interactables.size() > 0:
			var closest = get_closest_node(interactables)
			if closest is RigidBody2D:  # For pickups
				held_item = closest
				is_holding_item = true
				if held_item.has_method("on_pickup"):
					held_item.on_pickup(self)
			elif closest.has_method("interact"):  # For interactables
				closest.interact(self)
		elif is_holding_item:
			drop_item()

func handle_movement(delta: float) -> void:

	input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("move_left", "move_right")
	input_vector.y = Input.get_axis("move_up", "move_down")
	input_vector = input_vector.normalized()

	if input_vector != Vector2.ZERO:
		if(input_vector.x > 0):
			$PlayerSprite.flip_h = false
		else:
			$PlayerSprite.flip_h = true
		$PlayerAnimation.play("walk-right")
		current_velocity += input_vector * acceleration * delta
		current_velocity = current_velocity.limit_length(max_speed)
	else:
		if current_velocity.length() > (friction * delta):
			current_velocity -= current_velocity.normalized() * friction * delta
		else:
			current_velocity = Vector2.ZERO
			$PlayerAnimation.play("idle")

	velocity = current_velocity
	move_and_slide()

	#if input_vector != Vector2.ZERO:
		#var target_rotation = input_vector.angle()
		#sprite.rotation = lerp_angle(sprite.rotation, target_rotation, rotation_speed * delta)
	#Handle animation changes

func handle_aim() -> void:
	if Input.is_action_pressed("aim"):
		var mouse_pos = get_global_mouse_position()
		var aim_direction = (mouse_pos - global_position).normalized()
		sprite.rotation = aim_direction.angle()

		if is_holding_item and held_item.has_method("aim"):
			held_item.aim(aim_direction)

func drop_item() -> void:
	if held_item and held_item.has_method("on_drop"):
		held_item.on_drop(self)
	held_item = null
	is_holding_item = false

func get_interactables_in_range() -> Array:
	var items = []
	for body in interaction_area.get_overlapping_bodies():
		if body is RigidBody2D or body.has_method("interact"):
			items.append(body)
	return items

func get_closest_node(nodes: Array) -> Node:
	var closest_node = nodes[0]
	var closest_distance = global_position.distance_to(nodes[0].global_position)

	for node in nodes:
		var distance = global_position.distance_to(node.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_node = node

	return closest_node

func check_fire_proximity() -> void:
	if get_tree().paused:
		return
		
	var fires = get_tree().get_nodes_in_group("fires")
	var found_close_fire = false
	
	for fire in fires:
		if not is_instance_valid(fire):
			continue
			
		var distance = global_position.distance_to(fire.global_position)
		
		if distance < fire_detection_distance:
			if not fire.discovered:
				exclamation.visible = true
				var timer = Timer.new()
				add_child(timer)
				timer.wait_time = 2.0
				timer.one_shot = true
				timer.timeout.connect(func(): 
					if is_instance_valid(exclamation):
						exclamation.visible = false
					timer.queue_free()
				)
				timer.start()
			
			if is_instance_valid(fire) and not fire.discovered:
				fire.discover()
				
		if distance < 200.0:
			found_close_fire = true
	
	if found_close_fire:
		if health_bar_timer.is_stopped():
			health_bar_timer.start()
	else:
		health_bar_timer.stop()

func _on_health_bar_value_changed(change: float) -> void:
	if damage_start == true:
		damage_start = false
		var new_value = health_bar.value - change
		health_bar.value = new_value
		print(health_bar.value)

func _on_health_bar_timer_timeout() -> void:
	_on_health_bar_value_changed(10)
	damage_start = true

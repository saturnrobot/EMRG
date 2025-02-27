extends CharacterBody2D

class_name PlayerController

@export var max_speed: float = 300.0
@export var acceleration: float = 2000.0
@export var friction: float = 1000.0
@export var rotation_speed: float = 10.0

@export var interaction_distance: float = 64.0
@export var grab_distance: float = 48.0

var input_vector: Vector2 = Vector2.ZERO
var current_velocity: Vector2 = Vector2.ZERO
var is_holding_item: bool = false
var held_item = null

@onready var sprite: Sprite2D = $Sprite2D
@onready var interaction_ray: RayCast2D = $InteractionRay

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	handle_interaction()
	handle_grab()
	handle_aim()

func handle_movement(delta: float) -> void:

	input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("move_left", "move_right")
	input_vector.y = Input.get_axis("move_up", "move_down")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		current_velocity += input_vector * acceleration * delta
		current_velocity = current_velocity.limit_length(max_speed)
	else:
		if current_velocity.length() > (friction * delta):
			current_velocity -= current_velocity.normalized() * friction * delta
		else:
			current_velocity = Vector2.ZERO
	
	velocity = current_velocity
	move_and_slide()
	
	if input_vector != Vector2.ZERO:
		var target_rotation = input_vector.angle()
		sprite.rotation = lerp_angle(sprite.rotation, target_rotation, rotation_speed * delta)

func handle_interaction() -> void:
	if Input.is_action_just_pressed("interact"):
		var collider = interaction_ray.get_collider()
		if collider and collider.has_method("interact"):
			collider.interact(self)

func handle_grab() -> void:
	if Input.is_action_just_pressed("grab"):
		if is_holding_item:
			drop_item()
		else:
			try_grab_item()

func handle_aim() -> void:
	if Input.is_action_pressed("aim"):
		var mouse_pos = get_global_mouse_position()
		var aim_direction = (mouse_pos - global_position).normalized()
		sprite.rotation = aim_direction.angle()
		
		if is_holding_item and held_item.has_method("aim"):
			held_item.aim(aim_direction)

func try_grab_item() -> void:
	var closest_item = find_closest_grabbable_item()
	if closest_item:
		held_item = closest_item
		is_holding_item = true
		
		if held_item.has_method("on_pickup"):
			held_item.on_pickup(self)

func drop_item() -> void:
	if held_item and held_item.has_method("on_drop"):
		held_item.on_drop(self)
	held_item = null
	is_holding_item = false

func find_closest_grabbable_item():
	pass

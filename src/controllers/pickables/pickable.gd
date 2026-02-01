class_name Pickable
extends CharacterBody2D

const BOUNCE_THRESHOLD: float = 200.0
const DROP_FORCE: float = 1300.0
const DROP_FORCE_MULTIPLIER: Vector2 = Vector2(1.0, 1.0)
const ROTATE_AMOUNT: float = 0.8

const MAX_IMPACT_FORCE:float = 2500.0

const SNAP_TIME: float = 0.1
const SNAP_HEIGHT: float = -20.0

@export var bounce: float = 0.2
@export var should_rotate: bool = false

var interactible: bool
var original_parent: Node2D
var target: Node2D

var snapping: bool
var snap_from: Vector2
var snap_to: Vector2
var snap_time: float = 0.0
var current_snap_time: float = 0.0

var was_on_floor: bool
var last_velocity: Vector2

@onready var sprite: Node2D = $Sprite
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	original_parent = get_parent()
	interactible = true
	top_level = true

func _physics_process(delta: float) -> void:
	if snapping:
		if target != null:
			snap_to = target.global_position
		update_snap(delta)
		return
	
	if target !=null:
		position = target.global_position
		return
	
	was_on_floor = is_on_floor()
	last_velocity = velocity
	
	if !is_on_floor():
		velocity.y += Constants.GRAVITY * delta * 2.0
	
	if should_rotate:
		global_rotation_degrees += velocity.x * ROTATE_AMOUNT * delta
	
	move_and_slide()
	
	if is_on_floor():
		
		if !was_on_floor:
			if last_velocity.length() > BOUNCE_THRESHOLD:
				velocity.y = -last_velocity.y * bounce
				velocity.x *= bounce
				
				var force_percent = inverse_lerp(0.0, MAX_IMPACT_FORCE, last_velocity.length())
				FmodServer.play_one_shot_attached_with_params("event:/Pickables/wood", self, {"force": force_percent})
			else:
				velocity = Vector2.ZERO
		else:
			if abs(velocity.x) > 0.1:
				velocity.x *= bounce
			else:
				velocity.x = 0.0
	
	if is_on_wall_only():
		if last_velocity.length() > BOUNCE_THRESHOLD:
			var force_percent = inverse_lerp(0.0, MAX_IMPACT_FORCE, last_velocity.length())
			FmodServer.play_one_shot_attached_with_params("event:/Pickables/wood", self, {"force": force_percent})
			velocity.x = -last_velocity.x * bounce

func snap(to: Vector2, time: float = -1.0):
	snap_from = global_position
	snap_to = to
	current_snap_time = 0.0
	snapping = true
	snap_time = time if time > 0.0 else SNAP_TIME

func update_snap(delta):
	if !should_rotate:
		global_rotation_degrees = 0.0
	
	current_snap_time += delta
	
	if current_snap_time >= snap_time:
		global_position = snap_to
		snapping = false
		velocity = Vector2.ZERO
		return
	
	var t = current_snap_time / snap_time
	var pos = snap_from.lerp(snap_to, t)
	pos.y += SNAP_HEIGHT * (1 - (2 * t - 1) * (2 * t - 1))
	global_position = pos

func pickup(new_target: Node2D):
	if !interactible:
		return
	
	target = new_target
	collision.disabled = true
	snap(target.global_position)
	

func drop(new_vel: Vector2 = Vector2.ZERO):
	target = null
	snapping = false
	interactible = false
	
	velocity = new_vel * DROP_FORCE_MULTIPLIER * DROP_FORCE
	collision.disabled = false
	
	await get_tree().create_timer(0.25).timeout
	
	interactible = true

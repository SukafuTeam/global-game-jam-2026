class_name Pickable
extends CharacterBody2D

const BOUNCE_THRESHOLD: float = 200.0
const DROP_FORCE: float = 1300.0
const DROP_FORCE_MULTIPLIER: Vector2 = Vector2(1.0, 1.0)
const ROTATE_AMOUNT: float = 0.8

const MAX_IMPACT_FORCE:float = 2000.0

const SNAP_TIME: float = 0.1
const SNAP_HEIGHT: float = -20.0

enum MaterialType {
	DEFAULT,
	SOFT,
	HEAVY,
	WOOD,
	METAL,
	GLASS,
	COCONUT
}

@export var bounce: float = 0.2
@export var should_rotate: bool = false
@export var type: MaterialType

var spawn_point: Vector2

var interactible: bool
var additional_velocity: Vector2
var original_parent: Node2D
var target: Node2D
var time_alive: float = 0.0

var snapping: bool
var snap_from: Vector2
var snap_to: Vector2
var snap_time: float = 0.0
var current_snap_time: float = 0.0

var was_on_floor: bool
var last_velocity: Vector2

@onready var sprite: Sprite2D = $Sprite
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	spawn_point = global_position
	original_parent = get_parent()
	interactible = true
	if should_rotate:
		global_rotation_degrees = randf_range(-30, 30)

func _physics_process(delta: float) -> void:
	time_alive += delta
	if snapping:
		if target != null:
			snap_to = target.global_position
		update_snap(delta)
		return
	
	if target !=null:
		global_position = target.global_position
		return
	
	if !is_on_floor():
		velocity.y += Constants.GRAVITY * delta * 2.0
	
	was_on_floor = is_on_floor()
	last_velocity = velocity
	
	if should_rotate:
		global_rotation_degrees += velocity.x * ROTATE_AMOUNT * delta
	
	move_and_slide()
	
	if is_on_floor():
		
		if !was_on_floor:
			if abs(last_velocity.y) > BOUNCE_THRESHOLD:
				velocity.y = -last_velocity.y * bounce
				velocity.x *= bounce
				
				if time_alive > 3.0:
					var force_percent = inverse_lerp(0.0, MAX_IMPACT_FORCE, last_velocity.length())
					play_sfx(force_percent)
			else:
				velocity = Vector2.ZERO
		else:
			if abs(velocity.x) > 0.1:
				velocity.x *= bounce
			else:
				velocity.x = 0.0
	
	if is_on_wall_only():
		if abs(last_velocity.x) > BOUNCE_THRESHOLD:
			if time_alive > 3.0:
				var force_percent = inverse_lerp(0.0, MAX_IMPACT_FORCE, last_velocity.length())
				play_sfx(force_percent)
			velocity.x = -last_velocity.x * bounce

func snap(to: Vector2, time: float = -1.0):
	snap_from = global_position
	snap_to = to
	current_snap_time = 0.0
	snapping = true
	collision.set_deferred("disabled", true)
	snap_time = time if time > 0.0 else SNAP_TIME

func update_snap(delta):
	if !should_rotate:
		global_rotation_degrees = 0.0
	
	current_snap_time += delta
	
	if current_snap_time >= snap_time:
		global_position = snap_to
		snapping = false
		velocity = Vector2.ZERO
		if target == null:
			collision.disabled = false
		return
	
	var t = current_snap_time / snap_time
	var pos = snap_from.lerp(snap_to, t)
	pos.y += SNAP_HEIGHT * (1 - (2 * t - 1) * (2 * t - 1))
	global_position = pos

func pickup(new_target: Node2D):
	if !interactible:
		return
	
	z_index += 1
	target = new_target
	collision.disabled = true
	snap(target.global_position)
	
	Global.item_picked.emit(self)
	

func drop(new_vel: Vector2 = Vector2.ZERO):
	target = null
	snapping = false
	interactible = false
	
	z_index -= 1
	Global.item_dropped.emit(self)
	
	velocity = new_vel * DROP_FORCE_MULTIPLIER * DROP_FORCE
	collision.set_deferred("disabled", false)
	
	await get_tree().create_timer(0.25).timeout
	
	interactible = true

func play_sfx(force_percent: float):
	if (global_position - Global.player.global_position).length() > 1500:
		return
	
	var event = "event:/Pickables/"
	
	match type:
		MaterialType.DEFAULT:
			event += "soft"
		MaterialType.SOFT:
			event += "soft"
		MaterialType.HEAVY:
			event += "heavy"
		MaterialType.WOOD:
			event += "wood"
		MaterialType.METAL:
			event += "metal"
		MaterialType.GLASS:
			event += "glass"
		MaterialType.COCONUT:
			event += "coconut"
			
	FmodServer.play_one_shot_attached_with_params(event, self, {"force": force_percent})

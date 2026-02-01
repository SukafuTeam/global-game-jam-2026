class_name PlayerController
extends CharacterBody2D

const INPUT_BUFFER_TIME: float = 0.1
const HOLD_BUFFER_TIME: float = 0.5

const MOVE_SPEED: float = 800.0
const SPEED_MULTIPLIER: float = 1.5
const ACCEL: float = 6000.0
const MAX_FALL_SPEED: float = 2000.0

const JUMP_FORCE: float = 930.0
const FALL_GRAVITY_MULTIPLIER: float = 3.0

const MAX_WALL_JUMP_FALL_SPEED: float = 400.0
const WALL_JUMP_SPEED: float = 500.0
const WALL_JUMP_MOVE_TIME: float = 0.15

const DASH_TIME: float = 0.3
const DASH_SPEED: Vector2 = Vector2(2500.0, 1700.0)

const DAMAGE_TIME: float = 1.0
const IFRAME_TIME: float = 3.0

const SCALE_DELTA: float = 1.0
const JUMP_SCALE: Vector2 = Vector2(0.8, 1.2)
const LAND_SCALE: Vector2 = Vector2(1.2, 0.8)


enum State {
	GROUND,
	AIR,
	DASH,
	DAMAGE,
	VICTORY
}


var state: State:
	set(value):
		if value != state:
			exit_state(state)
			enter_state(value)
		state = value
	get:
		return state
var current_state_time: float = 0.0
var looking_right: bool
var last_velocity: Vector2
var additional_velocity: Vector2
var was_on_floor: bool
var can_double_jump: bool
var can_dash: bool
var dash_cooldown: float = -1.0

var health: int
var current_iframe_time: float = -1.0

var current_auto_move_time: float = 0.0
var auto_move_speed: float = 0.0
var current_coyote_time: float = 0.0
var current_jump_buffer_time: float = -1.0
var current_hold_buffer_time: float = -1.0
var current_dash_buffer_time: float = -1.0
var current_up_buffer_time: float = -1.0
var current_kick_time: float = -1.0

var current_left_wall_slide_time: float = -1.0
var current_right_wall_slide_time: float = -1.0
var wall_sliding: bool:
	get:
		return current_left_wall_slide_time > 0.0 or \
			current_right_wall_slide_time > 0.0
var left_wall_check: bool:
	get:
		return left_wall_check_1.is_colliding() and left_wall_check_2.is_colliding()
var right_wall_check: bool:
	get:
		return right_wall_check_1.is_colliding() and right_wall_check_2.is_colliding()

var holding_item: Pickable

@onready var body_container: Node2D = $BodyContainer
@onready var sprite: SpineSprite = $BodyContainer/SpineSprite

@onready var ground_check: RayCast2D = $Checks/GroundCheck
@onready var left_wall_check_1: RayCast2D = $Checks/LeftWallCheck1
@onready var left_wall_check_2: RayCast2D = $Checks/LeftWallCheck2
@onready var right_wall_check_1: RayCast2D = $Checks/RightWallCheck1
@onready var right_wall_check_2: RayCast2D = $Checks/RightWallCheck2
@onready var hitbox:Area2D = $Hitbox

@onready var left_pick_check: Area2D = $PickChecks/LeftPickCheck
@onready var right_pick_check: Area2D = $PickChecks/RightPickCheck
@onready var left_anchor: Marker2D = $BodyContainer/SpineSprite/SpineSlotNode/LeftPickAnchor
@onready var right_anchor: Marker2D = $BodyContainer/SpineSprite/SpineSlotNode/RightPickAnchor
@onready var left_holding_collision: CollisionPolygon2D = $LeftHoldingCollision
@onready var right_holding_collision: CollisionPolygon2D = $RightHoldingCollision

@onready var footstep_particle: CPUParticles2D = $Particles/FootStepParticle
@onready var speed_footstep_particle: CPUParticles2D = $Particles/SpeedFootStepParticle
@onready var dash_explostion_particle: CPUParticles2D = $Particles/DashExplosion
@onready var dash_particle: CPUParticles2D = $Particles/DashParticle
@onready var right_jump_particle: CPUParticles2D = $Particles/RightJumpParticle
@onready var left_jump_particle: CPUParticles2D = $Particles/LeftJumpParticle
@onready var double_jump_particle: CPUParticles2D = $Particles/DoubleJumpParticle
@onready var high_jump_particle: CPUParticles2D = $Particles/HighJumpParticle
@onready var left_wall_slide_particle: CPUParticles2D = $Particles/LeftWallSlideParticle
@onready var right_wall_slide_particle: CPUParticles2D = $Particles/RightWallSlideParticle

func _ready() -> void:
	looking_right = true
	state = State.GROUND
	can_dash = Global.dash_enabled
	can_double_jump = Global.double_jump_enabled
	change_animation("idle")
	
	var skin_name = "masked" if Global.masked else "unmasked"
	var skin: SpineSkin = sprite.get_skeleton().get_data().find_skin(skin_name)
	sprite.get_skeleton().set_skin(skin)
	sprite.animation_event.connect(on_animation_event)
	
	health = Constants.INITIAL_HEALTH
	if Global.extra_health_enabled:
		health += 1
	
	Global.safe_item_position = global_position
	
	

func _process(delta: float) -> void:
	update_body_scale(delta)
	update_animation()
	update_partiles()
	
	if state == State.DAMAGE:
		sprite.modulate = Color(1.0, 0.5, 0.5)
	else:
		sprite.modulate = Color.WHITE
	
	if current_iframe_time >= 0.0 and state != State.DAMAGE:
		sprite.modulate.a = 0.4
	else:
		sprite.modulate.a = 1.0
	
	current_auto_move_time -= delta
	current_coyote_time -= delta
	current_jump_buffer_time -= delta
	current_dash_buffer_time -= delta
	current_hold_buffer_time -= delta
	current_up_buffer_time -= delta
	current_kick_time -= delta
	
	current_iframe_time -= delta
	dash_cooldown -= delta
	
	current_left_wall_slide_time -= delta
	current_right_wall_slide_time -= delta
	
	if Input.is_action_just_pressed("jump"):
		current_jump_buffer_time = INPUT_BUFFER_TIME
	if Input.is_action_just_pressed("hold"):
		current_hold_buffer_time = HOLD_BUFFER_TIME
	if Input.is_action_just_pressed("dash"):
		current_dash_buffer_time = INPUT_BUFFER_TIME
	if Input.is_action_pressed("up"):
		current_up_buffer_time = INPUT_BUFFER_TIME

func _physics_process(delta: float) -> void:
	if is_on_floor():
		current_coyote_time = INPUT_BUFFER_TIME
	else:
		# Adds gravity
		var grav = Constants.GRAVITY
		if velocity.y > 0.0:
			grav *= FALL_GRAVITY_MULTIPLIER
			
			if Global.high_jump_enabled:
				grav *= 1.5
		
		velocity.y += grav * delta
		
		velocity.y = min(velocity.y, MAX_FALL_SPEED)
		
		if (is_on_wall_only() or left_wall_check or right_wall_check) and Global.wall_jump_enabled:
			if left_wall_check and Input.is_action_pressed("left"):
				current_left_wall_slide_time = INPUT_BUFFER_TIME
				looking_right = true
			if right_wall_check and Input.is_action_pressed("right"):
				current_right_wall_slide_time = INPUT_BUFFER_TIME
				looking_right = false

	# Can't turn around while dashing or wallsliding
	if state != State.DASH and\
		current_auto_move_time < 0.0 and\
		!wall_sliding:
		var input_axis = Input.get_axis("left", "right")
		if abs(input_axis) > 0.1:
			looking_right = input_axis > 0.0
	
	process_hold()
	
	check_damage()
	
	match state:
		State.GROUND:
			state = process_ground(delta)
		State.AIR:
			state = process_air(delta)
		State.DASH:
			state = process_dash(delta)
		State.DAMAGE:
			state = process_damage(delta)
	
	was_on_floor = is_on_floor()
	velocity += additional_velocity
	last_velocity = velocity
	
	move_and_slide()
	additional_velocity = Vector2.ZERO
	
	if is_on_floor() and !was_on_floor:
		on_land(last_velocity.y)

#region State methods
func check_damage():
	if current_iframe_time >= 0.0:
		return
	
	if hitbox.get_overlapping_areas().is_empty():
		return
	
	health -= 1
	#TODO: gameover logic
	
	FmodServer.play_one_shot_with_params("event:/Character/footsteps", {"Surface": 1})
	
	if holding_item:
		holding_item.drop(Vector2(randf_range(--0.5, 0.5), -0.2))
		holding_item = null
	
	Global.set_camera_stress(Vector2.ONE)
	state = State.DAMAGE
	current_state_time = DAMAGE_TIME
	current_iframe_time = IFRAME_TIME
	velocity = Vector2(0.0, -300)
	
func process_ground(delta: float) -> State:
	input_move(delta)
	
	if current_dash_buffer_time >= 0.0 and can_dash and Global.dash_enabled and dash_cooldown <= 0.0:
		var should_dash = true
		if looking_right and right_wall_check:
			should_dash = false
		if !looking_right and left_wall_check:
			should_dash = false
		if should_dash:
			return State.DASH
		else:
			current_dash_buffer_time = 0.0
	
	if current_jump_buffer_time >= 0.0 and current_coyote_time:
		on_jump()
		return State.AIR
		
	if current_coyote_time <= 0.0:
		return State.AIR
	
	return State.GROUND

func process_air(delta: float) -> State:
	input_move(delta)
	
	if current_dash_buffer_time >= 0.0 and can_dash and Global.dash_enabled and dash_cooldown <= 0.0 and !left_wall_check and !right_wall_check:
		if wall_sliding:
			looking_right = !looking_right
		can_dash = false
		current_dash_buffer_time = 0.0
		return State.DASH
	
	if wall_sliding:
		can_double_jump = true
		if dash_cooldown <= 0.0:
			can_dash = true
		
		velocity.y = min(velocity.y, MAX_WALL_JUMP_FALL_SPEED)
		
		if current_jump_buffer_time > 0.0:
			if current_left_wall_slide_time > 0.0:
				on_jump(true)
				current_auto_move_time = WALL_JUMP_MOVE_TIME
				auto_move_speed = WALL_JUMP_SPEED
				return State.AIR
			elif current_right_wall_slide_time > 0.0:
				on_jump(true)
				current_auto_move_time = WALL_JUMP_MOVE_TIME
				auto_move_speed = -WALL_JUMP_SPEED
				return State.AIR
	
	if can_double_jump and Global.double_jump_enabled:
		if current_jump_buffer_time >= 0.0:
			can_double_jump = false
			on_jump()
			return State.AIR
		
	
	if is_on_floor():
		return State.GROUND
	
	return State.AIR

func process_dash(delta) -> State:
	velocity.y = 0.0
	current_state_time -= delta
	
	if is_on_wall() or left_wall_check or right_wall_check:
		current_state_time = -1.0
	
	if current_state_time < 0.0:
		velocity.x /= 2
		if current_coyote_time >= 0.0:
			return State.GROUND
		else:
			return State.AIR
	
	if current_coyote_time >= 0.0 and current_jump_buffer_time >= 0.0:
		on_jump()
		return State.AIR
	
	var dash_percent = inverse_lerp(0.0, DASH_TIME, current_state_time)
	var current_dash_speed = lerp(DASH_SPEED.x, DASH_SPEED.y, dash_percent)
	if !looking_right:
		current_dash_speed *= -1
	
	velocity.x = current_dash_speed
	return State.DASH

func process_damage(delta: float) -> State:
	current_state_time -= delta
	
	if current_state_time <= 0.0:
		return State.GROUND
		
	Global.set_camera_stress(Vector2.ONE * 0.3)
	
	return State.DAMAGE

#endregion

#region Hold methods
func process_hold():
	if state == State.DAMAGE:
		return
	
	left_holding_collision.disabled = true
	right_holding_collision.disabled = true
	
	if holding_item != null:
		if looking_right:
			right_holding_collision.disabled = false
		else:
			left_holding_collision.disabled = false
		
		if Input.is_action_pressed("hold"):
			var target = right_anchor if looking_right else left_anchor
			holding_item.target = target
			
			if (left_wall_check_1.is_colliding() or left_wall_check_2.is_colliding()) and\
				(right_wall_check_1.is_colliding() or right_wall_check_2.is_colliding()):
					holding_item.drop()
					holding_item = null
					velocity.y = 0.0
		else:
			var drop_vel = Vector2(0.0, -0.1)
			var input_axis = Input.get_axis("left", "right")
			var speed_percent = inverse_lerp(0.0, MOVE_SPEED,abs(velocity.x))
			speed_percent = clamp(speed_percent, 0.0, 1.0)
			if current_up_buffer_time >= 0.0:
				current_up_buffer_time = 0.0
				drop_vel = Vector2(speed_percent * 0.5 * sign(velocity.x), -1.0)
			elif abs(input_axis) > 0.1:
				drop_vel = Vector2(input_axis, -0.3)
			
			velocity.y = 0.0
			holding_item.drop(drop_vel)
			holding_item = null
			current_kick_time = INPUT_BUFFER_TIME
			FmodServer.play_one_shot_with_params("event:/Character/footsteps", {"Surface": 0})
			body_container.scale = LAND_SCALE
		return
	
	if current_hold_buffer_time < 0.0:
		return
	
	var pick_check = right_pick_check if looking_right else left_pick_check
	if pick_check.get_overlapping_bodies().is_empty():
		return
	
	for body in pick_check.get_overlapping_bodies():
		if !(body is Pickable):
			continue
		
		var p = body as Pickable
		if !p.interactible:
			continue
		
		var target = right_anchor if looking_right else left_anchor
		p.pickup(target)
		holding_item = p
		current_hold_buffer_time = 0.0
		return
	
#region Movement methods
func input_move(delta: float):
	var input_axis = Input.get_axis("left", "right")
	var move_target = input_axis * MOVE_SPEED
	var accel = ACCEL
	
	if Global.speed_enabled:
		move_target *= SPEED_MULTIPLIER
		accel *= SPEED_MULTIPLIER
	
	velocity.x = move_toward(velocity.x, move_target, accel * delta)
	
	if current_auto_move_time > 0.0:
		var speed = auto_move_speed
		if Global.speed_enabled:
			speed *= SPEED_MULTIPLIER
		velocity.x = speed
	

func on_jump(wall_jump: bool = false):
	current_jump_buffer_time = 0.0
	current_left_wall_slide_time = 0.0
	current_right_wall_slide_time = 0.0
	
	FmodServer.play_one_shot_with_params("event:/Character/footsteps", {"Surface": 0})
	
	velocity.y = -JUMP_FORCE
	if Global.high_jump_enabled:
		velocity.y = -JUMP_FORCE * 1.25
	body_container.scale = JUMP_SCALE
	
	if current_coyote_time >= 0.0:
		right_jump_particle.restart()
		left_jump_particle.restart()
	else:
		double_jump_particle.restart()
	current_coyote_time = 0.0

	
	if wall_jump:
		current_left_wall_slide_time = -1.0
		current_right_wall_slide_time = -1.0	
		return
			
	if Global.high_jump_enabled:
		var dir = Input.get_axis("left", "right")
		high_jump_particle.direction.x = -dir
		high_jump_particle.restart()

func on_land(_hit_velocity: float):
	body_container.scale = LAND_SCALE
	can_double_jump = true
	can_dash = true
	
	right_jump_particle.restart()
	left_jump_particle.restart()

#endregion

#region State methods

func enter_state(new_state: State):
	match new_state:
		State.DASH:
			current_dash_buffer_time = -1.0
			current_state_time = DASH_TIME
			dash_explostion_particle.direction = Vector2.LEFT if looking_right else Vector2.RIGHT
			dash_explostion_particle.restart()
			FmodServer.play_one_shot_with_params("event:/Character/footsteps", {"Surface": 0})

func exit_state(old_state: State):
	match old_state:
		State.DASH:
			dash_cooldown = DASH_TIME

#endregion

#region Animation methods
func update_body_scale(delta):
	body_container.scale = body_container.scale.move_toward(
			Vector2.ONE,
			SCALE_DELTA * delta
		)

func  update_animation():
	if state == State.DAMAGE:
		var entry = change_animation("dizzy", 0, 0.0)
		if entry != null:
			entry.set_time_scale(4.0)
		return
	
	if holding_item and Input.is_action_pressed("hold"):
		var track_entry: SpineTrackEntry = sprite.get_animation_state().set_animation("hold", true, 1)
		track_entry.set_alpha(5.0)
	else:
		sprite.get_animation_state().set_empty_animation(1, 0.2)
		
	if current_kick_time >= 0.0:
		var track_entry: SpineTrackEntry = sprite.get_animation_state().set_animation("kick", true, 2)
		track_entry.set_alpha(5.0)
	else:
		sprite.get_animation_state().set_empty_animation(2, 0.2)
	
	var skel_scale = 1.0 if looking_right else -1.0
	#if wall_sliding:
		#skel_scale *= -1.0
		
	sprite.get_skeleton().set_scale_x(skel_scale)
	#TODO: implement better animations
	match state:
		State.GROUND:
			if abs(velocity.x) > 0.1:
				if Global.speed_enabled:
					change_animation("run_fast")
				else:
					change_animation("run")
			else:
				change_animation("idle")
		State.AIR:
			if wall_sliding:
				change_animation("walljump")
				return
			
			if velocity.y <= 0.0:
				if Global.double_jump_enabled and can_double_jump:
					change_animation("jump")
				else:
					change_animation("double_jump")
			else:
				change_animation("fall")
		State.DASH:
			change_animation("dash", 0, 0.0)

func change_animation(new_anim: String, track_id: int = 0, mix_time: float = 0.01) -> SpineTrackEntry:
	var current = sprite.get_animation_state().get_current(0)
	if current != null:
		if sprite.get_animation_state().get_current(track_id).get_animation().get_name() == new_anim:
			return null
	
	var track_entry: SpineTrackEntry = sprite.get_animation_state().set_animation(new_anim, true, track_id)
	track_entry.set_mix_time(mix_time)
	track_entry.set_mix_blend(SpineConstant.MixBlend_Replace)
	
	return track_entry

func update_partiles():
	footstep_particle.emitting = state == State.GROUND and abs(velocity.x) >= MOVE_SPEED * 0.9 and !Global.speed_enabled
	speed_footstep_particle.emitting = state == State.GROUND and abs(velocity.x) >= MOVE_SPEED * 0.9 and Global.speed_enabled
	dash_particle.emitting = state == State.DASH
	
	left_wall_slide_particle.emitting = left_wall_check and Input.is_action_pressed("left") and Global.wall_jump_enabled and state == State.AIR
	right_wall_slide_particle.emitting = right_wall_check and Input.is_action_pressed("right") and Global.wall_jump_enabled and state == State.AIR
	
	if Global.speed_enabled == true and abs(velocity.x) > MOVE_SPEED:
		Global.set_camera_stress(Vector2.ONE * 0.25)

func on_animation_event(_sprite: SpineSprite, _state: SpineAnimationState, _track: SpineTrackEntry, event: SpineEvent):
	if event.get_data().get_event_name() != "footstep":
		return
	
	FmodServer.play_one_shot_with_params("event:/Character/footsteps", {"Surface": 0})


#endregion

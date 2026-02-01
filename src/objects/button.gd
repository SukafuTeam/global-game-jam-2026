class_name PlatformButton
extends Area2D

signal pressed
signal invalid

enum Type {
	ONE_SHOT,
	HOLD,
	TIMER
}

const IDLE_POS: float = -30
const VALID_POS: float = -20

@export var type: Type
@export var time: float = 10.0
@export var idle_texture: Texture
@export var valid_texture: Texture

var valid: bool:
	set(value):
		top_sprite.texture = valid_texture if value else idle_texture
		top_sprite.position.y = VALID_POS if value else IDLE_POS
		valid = value
	get:
		return valid

var current_valid_time: float = -1.0
var stale: bool
var was_valid: bool

@onready var top_sprite: Sprite2D = $Top

func _physics_process(delta: float) -> void:
	if stale:
		return
	
	if type == Type.TIMER and valid:
		current_valid_time -= delta
		if current_valid_time <= 0.0:
			valid = false
			invalid.emit()
	
	was_valid = valid
	
	if type == Type.HOLD:
		valid = false
	
	var bodies = get_overlapping_bodies()
	if bodies.is_empty():
		return
	
	match type:
		Type.ONE_SHOT:
			valid = true
			stale = true
			pressed.emit()
			FmodServer.play_one_shot("event:/Interactables/button")
		Type.HOLD:
			valid = true
			if valid and !was_valid:
				FmodServer.play_one_shot("event:/Interactables/button")
		Type.TIMER:
			current_valid_time = time
			valid = true
	

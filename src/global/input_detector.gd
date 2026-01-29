extends Node

signal input_changed()

enum GamepadType {XBOX, PLAYSTATION, NINTENDO}

var current_gamepad_type: GamepadType
var is_gamepad: bool:
	set(value):
		if value == true and is_gamepad == false:
			# detect controller type everytime we change input to gamepad
			current_gamepad_type = detect_controller_type(0)
		var should_emit = false
		if value != is_gamepad:
			should_emit = true
		is_gamepad = value
		if should_emit:
			input_changed.emit()
	get:
		return is_gamepad


# Input textures
@export_subgroup("Jump Fields")
@export var jump_texture_xbox: Texture2D
@export var jump_texture_playstation: Texture2D
@export var jump_texture_keyboard: Texture2D
@export var enter_texture_keyboard: Texture2D
@export var jump_texture_nintendo: Texture2D
var current_jump_texture: Texture2D:
	get:
		if !is_gamepad:
			return jump_texture_keyboard
		match current_gamepad_type:
			GamepadType.PLAYSTATION:
				return jump_texture_playstation
			GamepadType.NINTENDO:
				return jump_texture_nintendo
		return jump_texture_xbox

var current_enter_texture: Texture2D:
	get:
		if !is_gamepad:
			return enter_texture_keyboard
		match current_gamepad_type:
			GamepadType.PLAYSTATION:
				return jump_texture_playstation
			GamepadType.NINTENDO:
				return jump_texture_nintendo
		return jump_texture_xbox

@export_subgroup("Hold Fields")
@export var hold_texture_xbox: Texture2D
@export var hold_texture_playstation: Texture2D
@export var hold_texture_keyboard: Texture2D
@export var hold_texture_nintendo: Texture2D
var current_hold_texture: Texture2D:
	get:
		if !is_gamepad:
			return hold_texture_keyboard
		match current_gamepad_type:
			GamepadType.PLAYSTATION:
				return hold_texture_playstation
			GamepadType.NINTENDO:
				return hold_texture_nintendo
		return hold_texture_xbox

@export_subgroup("Dash Fields")
@export var dash_texture_xbox: Texture2D
@export var dash_texture_playstation: Texture2D
@export var dash_texture_keyboard: Texture2D
@export var back_texture_keyboard: Texture2D
@export var dash_texture_nintendo: Texture2D
var current_dash_texture: Texture2D:
	get:
		if !is_gamepad:
			return dash_texture_keyboard
		match current_gamepad_type:
			GamepadType.PLAYSTATION:
				return dash_texture_playstation
			GamepadType.NINTENDO:
				return dash_texture_nintendo
		return dash_texture_xbox
	
var current_back_texture: Texture2D:
	get:
		if !is_gamepad:
			return back_texture_keyboard
		match current_gamepad_type:
			GamepadType.PLAYSTATION:
				return dash_texture_playstation
			GamepadType.NINTENDO:
				return dash_texture_nintendo
		return dash_texture_xbox

@export_subgroup("Map Fields")
@export var map_texture_xbox: Texture2D
@export var map_texture_playstation: Texture2D
@export var map_texture_keyboard: Texture2D
@export var map_texture_nintendo: Texture2D
var current_map_texture: Texture2D:
	get:
		if !is_gamepad:
			return map_texture_keyboard
		match current_gamepad_type:
			GamepadType.PLAYSTATION:
				return map_texture_playstation
			GamepadType.NINTENDO:
				return move_texture_nintendo
		return map_texture_xbox

@export_subgroup("Totem Fields")
@export var totem_texture_xbox: Texture2D
@export var totem_texture_playstation: Texture2D
@export var totem_texture_keyboard: Texture2D
@export var totem_texture_nintendo: Texture2D
var current_totem_texture: Texture2D:
	get:
		if !is_gamepad:
			return totem_texture_keyboard
		match current_gamepad_type:
			GamepadType.PLAYSTATION:
				return totem_texture_playstation
			GamepadType.NINTENDO:
				return move_texture_nintendo
		return totem_texture_xbox

@export_subgroup("Move Fields")
@export var move_texture_xbox: Texture2D
@export var move_texture_playstation: Texture2D
@export var move_texture_keyboard: Texture2D
@export var move_texture_nintendo: Texture2D
var current_move_texture: Texture2D:
	get:
		if !is_gamepad:
			return move_texture_keyboard
		match current_gamepad_type:
			GamepadType.PLAYSTATION:
				return move_texture_playstation
			GamepadType.NINTENDO:
				return move_texture_nintendo
		return move_texture_xbox


func _input(event):
	var gamepad_move_input = Vector2(Input.get_joy_axis(0, JOY_AXIS_LEFT_X), Input.get_joy_axis(0, JOY_AXIS_LEFT_Y))
	if Input.is_action_just_pressed("keyboard_keys") or (event is InputEventMouse):
		is_gamepad = false
	elif Input.is_action_just_pressed("gamepad_keys") or gamepad_move_input.length() > 0.1:
		is_gamepad = true

func detect_controller_type(index: int) -> GamepadType:
	var raw_name = Input.get_joy_name(index)
	match raw_name:
		"Sony DualSense", "PS5 Controller", "PS4 Controller", \
		"Nacon Revolution Unlimited Pro Controller":
			return GamepadType.PLAYSTATION
		"Switch":
			return GamepadType.NINTENDO

	# By default return xbox layout
	return GamepadType.XBOX

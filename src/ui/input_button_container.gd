class_name InputButtonContainer
extends Control

enum InputType {
	JUMP,
	HOLD,
	DASH,
	MAP,
	TOTEM,
	MOVE,
	ENTER,
	BACK,
}

@onready var icon: TextureRect = $InputIcon

@export var type: InputType
@export var color: Color

func _ready():
	InputDetector.input_changed.connect(input_changed)
	icon.texture = get_texture()
	icon.modulate = color

func input_changed():
	icon.texture = get_texture()
	
func get_texture() -> Texture2D:
	match type:
		InputType.JUMP:
			return InputDetector.current_jump_texture
		InputType.HOLD:
			return InputDetector.current_hold_texture
		InputType.DASH:
			return InputDetector.current_dash_texture
		InputType.MAP:
			return InputDetector.current_map_texture
		InputType.TOTEM:
			return InputDetector.current_totem_texture
		InputType.MOVE:
			return InputDetector.current_move_texture
		InputType.ENTER:
			return InputDetector.current_enter_texture
		InputType.BACK:
			return InputDetector.current_back_texture
	
	return InputDetector.current_jump_texture

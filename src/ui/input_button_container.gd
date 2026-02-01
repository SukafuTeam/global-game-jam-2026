class_name InputButtonContainer
extends TextureRect

enum InputType {
	JUMP,
	HOLD,
	DASH,
	MAP,
	MOVE,
	ENTER,
	BACK,
}

@export var type: InputType
@export var color: Color

func _ready():
	InputDetector.input_changed.connect(input_changed)
	texture = get_proper_texture()
	modulate = color

func input_changed():
	texture = get_proper_texture()
	
func get_proper_texture() -> Texture2D:
	match type:
		InputType.JUMP:
			return InputDetector.current_jump_texture
		InputType.HOLD:
			return InputDetector.current_hold_texture
		InputType.DASH:
			return InputDetector.current_dash_texture
		InputType.MAP:
			return InputDetector.current_map_texture
		InputType.MOVE:
			return InputDetector.current_move_texture
		InputType.ENTER:
			return InputDetector.current_enter_texture
		InputType.BACK:
			return InputDetector.current_back_texture
	
	return InputDetector.current_jump_texture

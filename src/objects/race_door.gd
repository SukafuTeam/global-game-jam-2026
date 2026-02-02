extends Node2D

@export var time_button: PlatformButton
@export var open_button: PlatformButton

@export var total_time: float = 2.0
@export var move_curve: Curve
@export var final_offset: float = 256.0

var finished: bool

var original_position: float
var current_time: float
	
func _ready():
	original_position = position.y
	open_button.pressed.connect(final_move)
	move_curve.bake()

func _physics_process(delta):
	if finished:
		return
	
	if time_button.valid:
		current_time = total_time
	
	current_time -= delta
	
	var percent = inverse_lerp(total_time, 0.0, current_time)
	var curve_pos = move_curve.sample(percent)
	position.y = lerp(position.y,original_position + final_offset * curve_pos, 1.0 * delta)


func final_move():
	finished = true
	var tween = create_tween()
	tween.tween_property(self, "position:y", original_position + final_offset, total_time/2.0)

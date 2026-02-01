class_name MovingPlatform
extends AnimatableBody2D

@export var step_time: float = 2.0
@export var trans_type: Tween.TransitionType = Tween.TransitionType.TRANS_SINE

var points: Array[Vector2] = []
var current: int = 0

func _ready() -> void:
	for child in get_children():
		if !(child is Marker2D):
			continue
		
		points.append(child.global_position)
	
	if points.is_empty():
		push_warning("non moving platform setup, please add Marker2D children")
		return
	
	global_position = points[0]
	
	var tween = create_tween()
	tween.set_loops(-1)
	for point in points:
		tween.tween_property(
			self,
			"global_position",
			point,
			step_time
		).set_ease(Tween.EASE_IN_OUT).set_trans(trans_type)

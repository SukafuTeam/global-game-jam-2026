extends CanvasLayer

@export var left_wall_values: Vector2
@export var right_wall_values: Vector2

var can_change: bool

@onready var left_wall: TextureRect = $Container/LeftWall
@onready var right_wall: TextureRect = $Container/RightWall

func _ready():
	can_change = true
	left_wall.position.x = left_wall_values.x
	right_wall.position.x = right_wall_values.x

func transition(new_scene: String):
	if !can_change:
		return
	
	can_change = false
	
	left_wall.position.x = left_wall_values.x
	right_wall.position.x = right_wall_values.x
	
	var tween = create_tween()
	tween.tween_property(left_wall, "position:x", left_wall_values.y, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(right_wall, "position:x", right_wall_values.y, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(func(): get_tree().change_scene_to_file(new_scene))
	tween.tween_interval(1.0)
	tween.tween_property(left_wall, "position:x", left_wall_values.x, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(right_wall, "position:x", right_wall_values.x, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	can_change = true

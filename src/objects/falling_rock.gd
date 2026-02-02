extends PathFollow2D

@export var move_speed: float = 0.1

var rotate_amount: float = 30.0
var last_x: float

func _process(delta):
	progress_ratio += move_speed * delta
	
	rotation_degrees += (position.x - last_x) * rotate_amount * delta
	last_x = position.x

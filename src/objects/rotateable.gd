extends Node2D

@export var rotate_speed: float = 300.0

func _process(delta):
	global_rotation_degrees += rotate_speed * delta

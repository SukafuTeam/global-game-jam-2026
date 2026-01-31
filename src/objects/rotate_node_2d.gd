class_name RotateNode2D
extends Node2D

@export var rot: float = 100.0

func _process(delta: float) -> void:
	global_rotation_degrees += rot * delta

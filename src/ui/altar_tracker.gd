class_name AltarTracker
extends Node2D

@export var altar: AltarController

@onready var pivot: Node2D = $Pivot

func _ready():
	visible = false
	global_position = Global.camera.get_screen_center_position()

func _process(_delta: float) -> void:
	if altar.completed:
		queue_free()
		return
	
	visible = (global_position - altar.global_position).length() > 100.0
	
	var center = Global.camera.get_screen_center_position()
	var dir = altar.global_position - center
	pivot.global_rotation_degrees = rad_to_deg(atan2(dir.y, dir.x))
	
	var v_size = get_viewport_rect().size * 0.4
	var bounds_min = center - v_size
	var bounds_max = center + v_size
	global_position.x = clamp(altar.global_position.x, bounds_min.x, bounds_max.x)
	global_position.y = clamp(altar.global_position.y, bounds_min.y, bounds_max.y)

class_name ItemTracker
extends Node2D

@export var item: Pickable

@onready var pivot: Node2D = $Pivot
@onready var sprite: Sprite2D = $Item

var map_tracker: TrackerMapIcon

func _ready():
	visible = false
	global_position = Global.camera.get_screen_center_position()

func _process(_delta: float) -> void:
	if item  == null:
		queue_free()
		return
	
	visible = (global_position - item.global_position).length() > 100.0
	
	var center = Global.camera.get_screen_center_position()
	var dir = item.global_position - center
	pivot.global_rotation_degrees = rad_to_deg(atan2(dir.y, dir.x))
	
	var v_size = get_viewport_rect().size * 0.4
	var bounds_min = center - v_size + Vector2(0.0, 120.0)
	var bounds_max = center + v_size
	global_position.x = clamp(item.global_position.x, bounds_min.x, bounds_max.x)
	global_position.y = clamp(item.global_position.y, bounds_min.y, bounds_max.y)

func _exit_tree():
	Global.map.remove_tracker(map_tracker)

class_name CameraLimiter
extends Area2D

@onready var limit_min: Marker2D = $Min
@onready var limit_max: Marker2D = $Max

func _ready() -> void:
	area_entered.connect(on_body_entered)
	

func on_body_entered(other: Area2D):
	if !(other.owner is PlayerController):
		return
		
	Global.camera.limit_bottom = limit_min.global_position.y
	Global.camera.limit_left = limit_min.global_position.x
	Global.camera.limit_right = limit_max.global_position.x
	Global.camera.limit_top = limit_max.global_position.y

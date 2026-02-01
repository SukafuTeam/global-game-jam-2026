class_name Esteira
extends StaticBody2D

#@export var move_vel: Vector2 = Vector2.LEFT

#func _physics_process(_delta: float) -> void:
	#for area in get_overlapping_bodies():
		#if !(area is Pickable) and !(area is PlayerController):
			#continue
		#
		#var c = area as CharacterBody2D
		#c.additional_velocity = move_vel

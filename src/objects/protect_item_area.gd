class_name ProtectItemArea
extends Area2D

func _physics_process(_delta: float) -> void:
	if get_overlapping_bodies().is_empty():
		return
	
	for b in get_overlapping_bodies():
		if !(b is Pickable):
			continue
		
		var p = b as Pickable
		if p.target != null:
			continue
	
		Global.add_camera_stress(Vector2.ONE * 0.2)
		p.snap(Global.safe_item_position, 0.2)
		

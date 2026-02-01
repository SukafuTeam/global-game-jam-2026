class_name Key
extends Pickable

@export var color: Color
@export var lock_id: int

func _ready() -> void:
	super()
	if lock_id in Global.opened_locks:
		queue_free()
		return
	
	sprite.modulate = color
	
	

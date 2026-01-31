class_name SafeAreaSetter
extends Area2D

func _ready() -> void:
	body_entered.connect(on_body_entered)

func on_body_entered(other: Node2D):
	if !(other is PlayerController):
		return
	
	Global.safe_item_position = global_position

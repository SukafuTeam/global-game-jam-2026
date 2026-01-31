extends Node2D

@export var target: Sprite2D
@export var options: Array[Texture2D] = []

func _ready() -> void:
	if options.is_empty() or target == null:
		return
	
	target.texture = options.pick_random()

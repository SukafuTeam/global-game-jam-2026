extends Node2D

@export var buttons: Array[PlatformButton] = [] 

@export var destroy: Node2D

@export var mask: Area2D

var finished

func _ready() -> void:
	mask.body_entered.connect(func(other):
		if other is PlayerController:
			get_tree().change_scene_to_file("res://scenes/intro_cutscene.tscn")
	)

func _process(delta: float) -> void:
	if finished:
		return
		
	for button in buttons:
		if !button.valid:
			return
	
	destroy.queue_free()
	finished = true

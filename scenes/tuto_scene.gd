extends Node2D

@export var buttons: Array[PlatformButton] = [] 

@export var destroy: Node2D

@export var mask: Area2D

var finished

func _ready() -> void:
	mask.body_entered.connect(func(other):
		if other is PlayerController:
			finish_tutorial()
	)

func _process(_delta: float) -> void:
	if finished:
		return
		
	for button in buttons:
		if !button.valid:
			return
	
	destroy.queue_free()
	finished = true

func finish_tutorial():
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://scenes/intro_cutscene.tscn")

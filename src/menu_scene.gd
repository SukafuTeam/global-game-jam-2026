extends Control

func _ready():
	Global.reset()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/tuto_scene.tscn")
	
	if Input.is_action_just_pressed("dash") or Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

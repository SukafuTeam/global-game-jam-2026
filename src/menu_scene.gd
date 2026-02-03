extends Control

func _ready():
	Global.reset()
	
	if Global.menu_event.get_playback_state() == FmodEvent.FMOD_STUDIO_PLAYBACK_STATE.FMOD_STUDIO_PLAYBACK_PLAYING:
		return
	
	Global.menu_event.set_parameter_by_name("loop", 1.0)
	Global.menu_event.start()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_accept"):
		Global.menu_event.stop(0)
		get_tree().change_scene_to_file("res://scenes/tuto_scene.tscn")
	
	if Input.is_action_just_pressed("dash") or Input.is_action_just_pressed("ui_cancel"):
		Global.menu_event.stop(0)
		get_tree().quit()

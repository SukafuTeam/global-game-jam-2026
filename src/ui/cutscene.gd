extends Node2D

const INITIAL_X: float = 1920
const FINAL_X: float = -2000
const SKIP_THRESHOLD: float = 2.0

@export var slides: Array[Node2D] = []

@export var slide_time: float = 2.5

@export var intro: bool

var skip_buffer: float = 0.0

@onready var skip: TextureRect = $Skip

var elapsed_time: float = 0.0

var cutscene_ost: FmodEvent

func _ready() -> void:
	cutscene_ost = FmodServer.create_event_instance("event:/BGM/god")
	if intro:
		cutscene_ost.set_parameter_by_name("loop", 1)
	cutscene_ost.start()
	
	Global.masked = true
	var tween = create_tween()
	tween.tween_interval(1.0)
	
	var counter: int = 0
	
	for i in slides:
		i.global_position.x = INITIAL_X
		
		var time = slide_time
		if counter in [2, 3, 7, 8]:
			time = 1.5
		
		tween.tween_property(i, "position:x", 10.0, time*0.1)
		tween.tween_property(i, "position:x", -10.0, time*0.8)
		tween.tween_property(i, "position:x", FINAL_X, time*0.1)
		tween.tween_interval(0.1)
		
		counter += 1
	
	tween.tween_callback(func():
		cutscene_ost.release()
		if intro:
			print(elapsed_time)
			get_tree().change_scene_to_file("res://scenes/main_scene.tscn")
		else:
			print(elapsed_time)
			get_tree().change_scene_to_file("res://scenes/menu_scene.tscn")
	)
		
func _process(delta: float) -> void:
	elapsed_time += delta
	if intro and elapsed_time > 12:
		cutscene_ost.set_parameter_by_name("loop", 0.0)
	
	skip_buffer -= delta
	
	skip.visible = skip_buffer >= 0.0
	
	if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_accept"):
		if skip_buffer < 0:
			skip_buffer = SKIP_THRESHOLD
		else:
			cutscene_ost.stop(0)
			if intro:
				get_tree().change_scene_to_file("res://scenes/main_scene.tscn")
			else:
				get_tree().change_scene_to_file("res://scenes/menu_scene.tscn")

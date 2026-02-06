extends Node2D

const INITIAL_X: float = 1920
const FINAL_X: float = -2000

@export var slides: Array[Node2D] = []

@export var slide_time: float = 2.5

var skip_buffer: float = 0.0
var cutscene_ost: FmodEvent
var elapsed_time: float

@onready var skip: TextureRect = $Skip

func _ready() -> void:
	cutscene_ost = FmodServer.create_event_instance("event:/BGM/god")
	cutscene_ost.set_parameter_by_name("loop", 1.0)
	cutscene_ost.start()
	
	var tween = create_tween()
	tween.tween_interval(1.0)
	
	var counter = 0
	for i in slides:
		i.modulate.a = 0.0
		
		var time = slide_time
		if counter == 2:
			time *= 1.5
		tween.tween_property(i, "modulate:a", 1.0, time*0.2)
		tween.tween_interval(time * 0.6)
		tween.tween_property(i, "modulate:a", 0.0, time*0.2)
		tween.tween_interval(0.1)
		counter += 1
	
	tween.tween_callback(func():
		cutscene_ost.release()
		Transition.transition(Constants.MENU_SCENE)
	)
		
func _process(delta: float) -> void:
	skip_buffer -= delta
	skip.visible = skip_buffer >= 0.0
	elapsed_time += delta
	
	if elapsed_time >= 8:
		cutscene_ost.set_parameter_by_name("loop", 0.0)
	
	if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_accept"):
		if skip_buffer < 0:
			skip_buffer = Constants.SKIP_THRESHOLD
		else:
			cutscene_ost.stop(0)
			Transition.transition(Constants.MENU_SCENE)

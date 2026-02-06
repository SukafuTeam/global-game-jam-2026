extends Node2D

var elapsed_time: float = 0.0
var skip_buffer: float = 0.0
var cutscene_ost: FmodEvent

@onready var skip: TextureRect = $Skip

func _ready():
	Global.masked = true
	cutscene_ost = FmodServer.create_event_instance("event:/BGM/god")
	cutscene_ost.set_parameter_by_name("loop", 1.0)
	cutscene_ost.start()

func _process(delta):
	elapsed_time += delta
	if elapsed_time > 24:
		cutscene_ost.set_parameter_by_name("loop", 0.0)
	
	skip_buffer -= delta
	skip.visible = skip_buffer >= 0.0
	
	if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_accept"):
		if skip_buffer < 0:
			skip_buffer = Constants.SKIP_THRESHOLD
		else:
			cutscene_ost.stop(0)
			Transition.transition(Constants.MAIN_SCENE)

func finish():
	cutscene_ost.stop(0)
	Transition.transition(Constants.MAIN_SCENE)

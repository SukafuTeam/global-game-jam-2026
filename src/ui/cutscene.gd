extends Node2D

const INITIAL_X: float = 1920
const FINAL_X: float = -2000
const SKIP_THRESHOLD: float = 2.0

@export var slides: Array[Node2D] = []

@export var slide_time: float = 2.5

@export var intro: bool

var skip_buffer: float = 0.0

@onready var skip: TextureRect = $Skip

func _ready() -> void:
	Global.masked = true
	var tween = create_tween()
	tween.tween_interval(1.0)
	for i in slides:
		i.global_position.x = INITIAL_X
		
		tween.tween_property(i, "position:x", 10.0, slide_time*0.1)
		tween.tween_property(i, "position:x", -10.0, slide_time*0.8)
		tween.tween_property(i, "position:x", FINAL_X, slide_time*0.1)
		tween.tween_interval(0.1)
	
	tween.tween_callback(func():
		if intro:
			get_tree().change_scene_to_file("res://scenes/main_scene.tscn")
		else:
			get_tree().change_scene_to_file("res://scenes/menu_scene.tscn")
	)
		
func _process(delta: float) -> void:
	skip_buffer -= delta
	
	skip.visible = skip_buffer >= 0.0
	
	if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_accept"):
		if skip_buffer < 0:
			skip_buffer = SKIP_THRESHOLD
		else:
			if intro:
				get_tree().change_scene_to_file("res://scenes/main_scene.tscn")
			else:
				get_tree().change_scene_to_file("res://scenes/menu_scene.tscn")

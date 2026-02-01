extends Node2D

@export var jungle_backgorund: Parallax2D
@export var cave_background: Parallax2D

@onready var cave_area: Area2D = $CaveArea
@onready var jungle_area: Area2D = $JungleArea

var tween: Tween

func _ready() -> void:
	jungle_area.body_entered.connect(func(_other): change(true))
	cave_area.body_entered.connect(func(_other): change(false))
	
	cave_background.modulate.a = 0.0

func change(jungle: bool):
	var current = cave_background if jungle else jungle_backgorund
	var new = jungle_backgorund if jungle else cave_background
	
	Global.ground_surface = 0 if jungle else 1
	
	if tween:
		tween.kill()
		
	tween = create_tween()
	tween.set_parallel()
	tween.tween_property(
		current,
		"modulate:a",
		0.0,
		0.2
	)
	tween.tween_property(
		new,
		"modulate:a",
		1.0,
		0.2
	)

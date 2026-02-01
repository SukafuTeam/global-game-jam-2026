extends Node2D

var ori: Vector2
var elapsed_time: float

func _ready() -> void:
	ori = global_position

func _process(delta: float) -> void:
	elapsed_time += delta
	
	global_position.y = ori.y + sin(elapsed_time * 1) * 30

extends Node2D

var ori: Vector2
var elapsed_time: float

@export var sprite: Sprite2D

func _ready() -> void:
	ori = global_position
	
	if sprite == null:
		return
	
	var tween = create_tween()
	tween.set_loops(-1)
	tween.tween_property(sprite, "scale", Vector2.ONE * 0.215, 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(sprite, "scale", Vector2.ONE * 0.2, 0.1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	tween.tween_interval(0.1)
	tween.tween_property(sprite, "scale", Vector2.ONE * 0.21, 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(sprite, "scale", Vector2.ONE * 0.2, 0.1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	tween.tween_interval(0.5)
	

func _process(delta: float) -> void:
	elapsed_time += delta
	
	global_position.y = ori.y + sin(elapsed_time * 2) * 20

extends Sprite2D

func _ready():
	var tween = create_tween()
	tween.set_loops(-1)
	tween.tween_property(self, "scale", Vector2.ONE * 1.1, 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	tween.tween_interval(0.1)
	tween.tween_property(self, "scale", Vector2.ONE * 1.05, 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	tween.tween_interval(0.5)

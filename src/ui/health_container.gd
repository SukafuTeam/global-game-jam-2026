class_name HealthContainer
extends TextureRect

@onready var icon: TextureRect = $FrontIcon

func take_damage():
	icon.modulate = Color.LIGHT_CORAL
	icon.scale = Vector2.ONE * 1.5
	var tween = create_tween()
	tween.tween_property(icon, "scale", Vector2.ZERO, 0.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)

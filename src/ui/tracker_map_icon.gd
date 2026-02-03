class_name TrackerMapIcon
extends TextureRect

const OFFSET: Vector2 = Vector2(5.0, -55.0)

@onready var icon: TextureRect = $Icon

var target: Node2D

func _ready():
	var tween = create_tween()
	tween.set_loops(-1)
	tween.tween_property(self, "scale", Vector2.ONE * 1.2, 0.5)
	tween.tween_property(self, "scale", Vector2.ONE, 0.5)

func setup(_target: Node2D, icon_texture: Texture):
	target = _target
	icon.texture = icon_texture

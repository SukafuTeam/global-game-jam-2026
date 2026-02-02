extends Control
class_name LogoScene

@onready var logo_image: TextureRect = $Logo

@export var logo_sound: AudioStreamPlayer

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	logo_image.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(func(): logo_sound.play())
	tween.tween_property(logo_image, "modulate:a", 1, 2)
	tween.tween_interval(4.0)
	tween.tween_property(logo_image, "modulate:a", 0, 1)
	tween.tween_callback(func():
		var event = FmodServer.create_event_instance("event:/BGM/jungle")
		event.start()
		get_tree().change_scene_to_file("res://scenes/menu_scene.tscn")
	)

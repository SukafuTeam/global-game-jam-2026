extends Control
class_name LogoScene

@onready var logo_image: TextureRect = $Logo

func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	Global.menu_event.set_parameter_by_name("loop", 0.0)
	Global.menu_event.start()
	
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	logo_image.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_property(logo_image, "modulate:a", 1, 2)
	tween.tween_interval(3.0)
	tween.tween_property(logo_image, "modulate:a", 0, 1)
	tween.tween_callback(func():
		get_tree().change_scene_to_file("res://scenes/menu_scene.tscn")
	)

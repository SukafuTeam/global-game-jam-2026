extends Area2D

@onready var first_path: PathFollow2D = $FirstPath/PathFollow2D
@onready var second_path: PathFollow2D = $SecondPath/PathFollow2D
@onready var third_path: PathFollow2D = $ThirdPath/PathFollow2D

func _ready():
	body_entered.connect(play_intro)

func play_intro(_other: Node2D):
	var d = get_parent() as DeliveryManager
	d.mission_completed()
	
	first_path.progress_ratio = 0.0
	second_path.progress_ratio = 0.0
	third_path.progress_ratio = 0.0
	
	Global.player.interactible = false
	Global.player.velocity = Vector2.ZERO
	Global.camera.limit_enabled = false
	
	
	var tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_property(Global.camera, "global_position", first_path.global_position, 1.0)
	tween.tween_callback(func(): 
		Global.camera.reparent(first_path)
	)
	tween.tween_property(first_path, "progress_ratio", 1.0, 7.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_interval(1.0)
	tween.tween_callback(func(): Global.camera.reparent(second_path))
	tween.tween_property(second_path, "progress_ratio", 1.0, 9.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_interval(1.0)
	tween.tween_callback(func(): Global.camera.reparent(third_path))
	tween.tween_property(third_path, "progress_ratio", 1.0, 5.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_interval(0.5)
	tween.tween_callback(func():
		Global.camera.reparent(Global.player, false)
		Global.camera.limit_enabled = true
		Global.player.interactible = true
		queue_free()
	)

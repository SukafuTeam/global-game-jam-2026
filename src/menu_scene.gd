extends Control

@onready var filter: ColorRect = $Filter
@onready var logo: Sprite2D = $Logo
@onready var play: TextureRect = $Play
@onready var exit: TextureRect = $Exit

var tween: Tween
var done: bool

func _ready():
	Global.reset()
	
	if Global.menu_event.get_playback_state() != FmodEvent.FMOD_STUDIO_PLAYBACK_STATE.FMOD_STUDIO_PLAYBACK_PLAYING:
		Global.menu_event.set_parameter_by_name("loop", 1.0)
		Global.menu_event.start()
	
	var play_tween: Tween = create_tween()
	play_tween.set_loops(-1)
	play_tween.tween_property(play, "scale", Vector2.ONE * 1.1, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	play_tween.tween_property(play, "scale", Vector2.ONE, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	play_tween.tween_property(play, "scale", Vector2.ONE * 1.05, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	play_tween.tween_property(play, "scale", Vector2.ONE, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	play_tween.tween_interval(1.0)
	
	done = false
	
	var or_play = play.position.y
	var or_exit = exit.position.x
	
	logo.modulate.a = 0.0
	filter.modulate.a = 1.0
	play.position.y += 800
	exit.position.x -= 300
	
	tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_property(logo, "modulate:a", 1.0, 1.0)
	tween.tween_interval(1.0)
	tween.tween_property(filter, "modulate:a", 0.0, 1.5)
	tween.tween_property(play, "position:y", or_play, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.parallel().tween_property(exit, "position:x", or_exit, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	await tween.finished
	
	done = true

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_accept"):
		if !done:
			done = true
			tween.custom_step(10.0)
			tween.kill()
			return
		
		Global.menu_event.stop(0)
		Transition.transition(Constants.TUTO_SCENE)
	
	if Input.is_action_just_pressed("dash") or Input.is_action_just_pressed("ui_cancel"):
		Global.menu_event.stop(0)
		get_tree().quit()

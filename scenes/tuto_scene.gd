extends Node2D

@export var buttons: Array[PlatformButton] = [] 

@export var destroy: Node2D

@export var mask: Area2D
@export var collecting: CPUParticles2D
@export var collecting2: CPUParticles2D
@export var left_wall: CollisionShape2D
@export var mask_coll: CollisionShape2D

@export var player: PlayerController

var finished

var ost_event: FmodEvent

func _ready() -> void:
	ost_event = FmodServer.create_event_instance("event:/BGM/tuto")
	ost_event.start()
	
	Global.player.health = 10000000000
	mask.body_entered.connect(func(other):
		if other is PlayerController:
			finish_tutorial()
	)
	intro()

func intro():
	player.interactible = false
	await get_tree().create_timer(1.0).timeout
	player.auto_move_speed = player.MOVE_SPEED * 0.4
	player.current_auto_move_time = 0.02
	await get_tree().create_timer(2.0).timeout
	player.interactible = true
	left_wall.disabled = false

func _process(_delta: float) -> void:
	if finished:
		return
		
	for button in buttons:
		if !button.valid:
			return
	
	FmodServer.play_one_shot("event:/UI/yes")
	var wall_sfx: FmodEvent = FmodServer.create_event_instance("event:/Interactables/wall")
	wall_sfx.start()
	var tween = create_tween()
	tween.tween_property(destroy, "position:y", destroy.position.y + 320, 2.0)
	tween.tween_callback(func():
		wall_sfx.stop(0)
		wall_sfx.release()
	)
	finished = true

func finish_tutorial():
	mask_coll.set_deferred("disabled", true)
	player.interactible = false
	player.velocity = Vector2.ZERO
	collecting.emitting = true
	var tween = create_tween()
	tween.tween_property(Global.camera, "zoom", Vector2.ONE * 1.2, 3.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	FmodServer.play_one_shot("event:/UI/yes")
	await get_tree().create_timer(2.5).timeout
	collecting2.emitting = true
	await get_tree().create_timer(0.5).timeout
	collecting.emitting = false
	await get_tree().create_timer(2.0).timeout
	ost_event.stop(0)
	Transition.transition(Constants.INTRO_SCENE)
	#get_tree().change_scene_to_file("res://scenes/intro_cutscene.tscn")

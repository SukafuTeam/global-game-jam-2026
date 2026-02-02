class_name DoorWall
extends Node2D

@export var move_amount: Vector2 = Vector2(0, -100)
@export var move_time: float = 2.0
@export var button: PlatformButton
@export var lock: Lock

var moved: bool
var moving: bool

func _ready():
	if button != null:
		button.pressed.connect(on_move)
	if lock != null:
		lock.unlocked.connect(on_move)

func _process(_delta):
	if !moving:
		return
		
	Global.camera.set_stress(Vector2.ONE * 0.2)

func on_move():
	if moved:
		return
	
	moved = true
	moving = true
	
	var eve = FmodServer.create_event_instance("event:/Interactables/wall")
	eve.start()
	
	var tween = create_tween()
	tween.tween_property(self, "global_position", global_position + move_amount, move_time).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	eve.stop(0)
	moving = false
	

class_name Lock
extends StaticBody2D

@export var color: Color
@export var lock_id: int

@onready var search: Area2D = $SearchBox
@onready var sprite: Sprite2D = $Sprite
@onready var particle: CPUParticles2D = $OpenParticle
@onready var bubble_container: Node2D = $Sprite/BubbleContainer

var opened: bool
var elapsed_time: float = 0.0

func _ready() -> void:
	if lock_id in Global.opened_locks:
		queue_free()
		return
	
	sprite.modulate = color
	opened = false
	
	search.body_entered.connect(on_body_entered)
	
func _process(delta: float) -> void:
	elapsed_time += delta
	var y_offset = sin(elapsed_time * 2 + global_position.x) * 15
	sprite.position.y = y_offset 
	
	var sin_scale = (sin(elapsed_time * 5 + global_position.x) + 1)/2 * 0.3
	bubble_container.scale = Vector2.ONE + (Vector2.ONE * sin_scale)

func on_body_entered(other: Node2D):
	if opened:
		return
	
	if other is PlayerController:
		var p = other as PlayerController
		if p.holding_item == null:
			return
		if !(p.holding_item is Key):
			return
		var k = p.holding_item as Key
		if k.lock_id != lock_id:
			return
	
		p.holding_item.drop()
		p.holding_item = null
		open(k)
		
	if other is Key:
		var k = other as Key
		if k.lock_id == lock_id:
			open(k)

func open(k: Key):
	opened = true
	Global.opened_locks.append(lock_id)
	FmodServer.play_one_shot("event:/Interactables/unlock")
	FmodServer.play_one_shot("event:/UI/yes")
	k.queue_free()
	particle.restart()
	await particle.finished
	queue_free()

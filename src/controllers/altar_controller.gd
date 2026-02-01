class_name AltarController
extends Node2D

signal item_delivered(item: Pickable)

@export var fires: Array[CPUParticles2D] = []

var completed: bool


@onready var area: Area2D = $Area
@onready var delivered_container: Node2D = $DeliveredContainer
@onready var delivered_sprite: Sprite2D = $DeliveredContainer/DeliveredItem

@export var decoration: bool

func _ready() -> void:
	if !decoration:
		for fire in fires:
			fire.emitting = false
	delivered_container.visible = false
	area.body_entered.connect(on_body_entered)

func delivered(texture: Texture):
	if completed:
		return
	
	completed = true
	delivered_container.visible = true
	delivered_sprite.texture = texture
	for fire in fires:
		fire.emitting = true
	

func on_body_entered(other: Node2D):
	if completed:
		return
	
	if other is PlayerController:
		var p = other as PlayerController
		if p.holding_item == null:
			return
		if !(p.holding_item is Key):
			return
		item_delivered.emit(p.holding_item as Pickable)
		return
		
	if other is Pickable:
		var item = other as Pickable
		item_delivered.emit(item)

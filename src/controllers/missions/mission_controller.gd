class_name MissionController
extends Node2D

@export var spawn_point: Vector2
@export var item: Pickable

var target: AltarController

var item_tracker: ItemTracker
var altar_tracker: AltarTracker

func _ready() -> void:
	global_position = spawn_point
	
	item.spawn_point = item.global_position

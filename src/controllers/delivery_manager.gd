class_name DeliveryManager
extends Node2D


@export var item_tracker: PackedScene
@export var altar_tracker: PackedScene

@export var mission_scenes: Array[PackedScene] = []
@export var targets: Array[AltarController] = []

var current_mission: int
var missions_completed: int
var current_controllers: Array[MissionController] = []

func _ready() -> void:
	if targets.size() != 5:
		push_warning("Please configure stage")
		return
		
	missions_completed = -1
	mission_completed()
	
	Global.item_picked.connect(item_picked)
	Global.item_dropped.connect(item_dropped)

	
func item_picked(item: Pickable):
	for controller in current_controllers:
		if controller.item == item:
			if controller.item_tracker != null:
				controller.item_tracker.queue_free()
			controller.altar_tracker = spawn_altar_tracker(controller.target)
			

func item_dropped(item: Pickable):
	for controller in current_controllers:
		if controller.item == item:
			if controller.altar_tracker != null:
				controller.altar_tracker.queue_free()
			controller.item_tracker = spawn_item_tracker(controller.item)

func item_delivered(altar: AltarController, item: Pickable):
	var should_remove: int = -1
	for i in current_controllers.size():
		var controller = current_controllers[i]
		if altar == controller.target and item == controller.item:
			mission_completed()
			should_remove = i
			altar.delivered(controller.item.sprite.texture)
			item.queue_free()
	
	if should_remove == -1:
		return
	
	current_controllers.remove_at(should_remove)

func mission_completed():
	missions_completed += 1
	FmodServer.play_one_shot("event:/UI/yes")
	await get_tree().process_frame
	match missions_completed:
		0:
			prep_mission(0)
		1:
			prep_mission(1)
			prep_mission(2)
		3:
			prep_mission(3)
			prep_mission(4)
		5:
			get_tree().change_scene_to_file("res://scenes/victory.tscn")

func prep_mission(index: int):
	var mission = mission_scenes[index].instantiate() as MissionController
	add_child(mission)
	mission.target = targets[index]
	targets[index].item_delivered.connect(func(item: Pickable):
		item_delivered(targets[index], item)
	)
	mission.item_tracker = spawn_item_tracker(mission.item)
	current_controllers.append(mission)

func spawn_item_tracker(target: Pickable) -> ItemTracker:
	var tracker = item_tracker.instantiate() as ItemTracker
	add_child(tracker)
	tracker.item = target
	tracker.sprite.texture = target.sprite.texture
	return tracker

func spawn_altar_tracker(target: AltarController) -> AltarTracker:
	var tracker = altar_tracker.instantiate() as AltarTracker
	add_child(tracker)
	tracker.altar = target
	return tracker

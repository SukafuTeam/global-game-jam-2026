class_name MapController
extends ColorRect

const PLAYER_OFFSET: Vector2 = Vector2(-20, -35)
const MAP_CLOSE_Y: float = -1000.0
const MAP_OPEN_Y: float = 108.0
const BACKGROUND_CLOSE_VALUES = Vector2(0.0, 0.0)
const BACKGROUND_OPEN_VALUES = Vector2(1.2, 0.3)

@export var map_tracker_scene: PackedScene
@export var map_altar_icon: Texture

@onready var background: TextureRect = $Background
@onready var origin: Control = $Background/Origin
@onready var player_icon: TextureRect = $Background/Origin/PlayerIcon

var trackers: Array[TrackerMapIcon] = []

var should_open: bool
var opened: bool
var can_change: bool
var tween: Tween
var shader_lod: float
var shader_mix: float
var shader_material: ShaderMaterial

func _ready():
	visible = true
	opened = true
	Global.map = self
	shader_material = material as ShaderMaterial
	can_change = true
	background.position.y = MAP_CLOSE_Y

func _process(_delta):
	should_open = Global.player.interactible and Input.is_action_pressed("map")
	
	if should_open != opened and can_change:
		if should_open:
			map_show()
		else:
			map_hide()
	
	if !visible:
		return
	
	shader_material.set_shader_parameter("lod", shader_lod)
	shader_material.set_shader_parameter("mix_percentage", shader_mix)
	
	
	player_icon.position = to_map_size(Global.player.global_position) + PLAYER_OFFSET
	
	for tracker in trackers:
		if tracker.target == null:
			tracker.visible = false
			continue
		tracker.position = to_map_size(tracker.target.global_position) + tracker.OFFSET

func map_show():
	if tween:
		tween.kill()
	
	can_change = false
	tween = create_tween()
	tween.tween_property(self, "shader_lod", BACKGROUND_OPEN_VALUES.x, 0.1)
	tween.parallel().tween_property(self, "shader_mix", BACKGROUND_OPEN_VALUES.y, 0.1)
	
	tween.tween_property(background, "position:y", MAP_OPEN_Y, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	await tween.finished
	can_change = true
	opened = true

func map_hide():
	if tween:
		tween.kill()
		
	can_change = false
	tween = create_tween()
	tween.set_parallel()
	tween.tween_property(background, "position:y", MAP_CLOSE_Y, 0.3)
	tween.tween_property(self, "shader_lod", BACKGROUND_CLOSE_VALUES.x, 0.1)
	tween.tween_property(self, "shader_mix", BACKGROUND_CLOSE_VALUES.y, 0.1)
	
	
	await tween.finished
	can_change = true
	opened = false

func add_tracker(target: Node2D, icon: Texture = null) -> TrackerMapIcon:
	if icon == null:
		icon = map_altar_icon
	
	var tracker = map_tracker_scene.instantiate() as TrackerMapIcon
	origin.add_child(tracker)
	tracker.setup(target, icon)
	
	trackers.append(tracker)
	
	return tracker

func remove_tracker(tracker: TrackerMapIcon):
	var id: int = -1
	for i in trackers.size():
		if trackers[i] == tracker:
			id = i
	
	if id == -1:
		return
	
	trackers[id].queue_free()
	trackers.remove_at(id)
	
func to_map_size(global_pos: Vector2):
	return global_pos * 0.072

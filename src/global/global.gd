extends Node

signal item_picked(item: Pickable)
signal item_dropped(item: Pickable)

var camera: CameraController

var masked: bool = true
var double_jump_enabled: bool = true
var wall_jump_enabled: bool = true
var dash_enabled: bool = true
var speed_enabled: bool = false
var high_jump_enabled: bool = false
var extra_health_enabled: bool = false

var safe_item_position: Vector2

var opened_locks: Array[int] = []
var ground_surface: int = 0

@onready var item_tracker: PackedScene = load("res://entities/ui/item_tracker.tscn")

func _ready():
	process_mode = PROCESS_MODE_ALWAYS
	#reset()

func reset():
	opened_locks = []
	masked = false
	double_jump_enabled = false
	wall_jump_enabled = false
	dash_enabled = false
	speed_enabled = false
	high_jump_enabled = false
	extra_health_enabled = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

func add_camera_stress(stress: Vector2):
	if camera == null:
		return
	
	camera.add_stress(stress)

func set_camera_stress(stress: Vector2):
	if camera == null:
		return
	
	camera.set_stress(stress)

func hit_stop(time: float = 0.1):
	get_tree().paused = true
	await get_tree().create_timer(time).timeout
	get_tree().paused = false

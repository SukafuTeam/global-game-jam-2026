extends Node

var camera: CameraController

var masked: bool = true
var double_jump_enabled: bool = true
var wall_jump_enabled: bool = true
var dash_enabled: bool = true
var speed_enabled: bool = true
var high_jump_enabled: bool = true
var extra_health_enabled: bool = true

var safe_item_position: Vector2

func _ready():
	process_mode = PROCESS_MODE_ALWAYS
	reset()

func reset():
	pass

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

class_name CameraController
extends Camera2D

const MAX_OFFSET : Vector2 = Vector2(20.0, 20.0)
const SHAKE_REDUCTION : float = 0.9

var elapsed_time: float = 0.0
var stress : Vector2 = Vector2.ZERO

func _ready():
	Global.camera = self

func _process(delta):
	elapsed_time += delta
	
	var n_value = get_shake()
	var shake = stress * stress
	
	offset = Vector2.ZERO
	offset.x = (MAX_OFFSET.x * shake.x * n_value)
	offset.y = (MAX_OFFSET.y * shake.y * n_value)
	
	stress *= SHAKE_REDUCTION
	if stress.length() < 0.01:
		stress = Vector2.ZERO

func get_shake() -> float:
	return sin(elapsed_time * 50.0)

func add_stress(amount: Vector2):
	stress += amount

func set_stress(amount: Vector2):
	stress = amount

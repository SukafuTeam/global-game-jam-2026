extends PathFollow2D

const HIT_COOLDOWN: float = 0.1
const HIT_DISTANCE: float = 1500.0
const PATH_HIT_OFFSET: float = 0.005

@export var move_speed: float = 0.1
@export var hit_points: Array[float] = []

var rotate_amount: float = 30.0
var last_x: float
var current_hit_cooldown: float = -1.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var particle: CPUParticles2D = $HitParticle

func _process(delta):
	progress_ratio += move_speed * delta
	current_hit_cooldown -= delta
	
	var dist = (global_position - Global.player.global_position).length()
	if current_hit_cooldown <= 0.0 and Global.player.interactible and dist <= HIT_DISTANCE:
		for point in hit_points:
			if progress_ratio >= point and progress_ratio < point + PATH_HIT_OFFSET:
				current_hit_cooldown = HIT_COOLDOWN
				Global.camera.add_stress(Vector2.ONE * 0.6)
				FmodServer.play_one_shot("event:/Interactables/boulder")
				particle.restart()
	
	
	sprite.rotation_degrees += (position.x - last_x) * rotate_amount * delta
	last_x = position.x

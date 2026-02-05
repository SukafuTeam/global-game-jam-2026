class_name Spring
extends Area2D

@export var impulse_force: float = 2000.0

var tween: Tween

@onready var body_container: Node2D = $BodyContainer

func _ready() -> void:
	body_entered.connect(on_body_entered)

func on_body_entered(other: Node2D):
	var c = other as CharacterBody2D
	
	if (c is PlayerController):
		var p = c as PlayerController
		p.state = PlayerController.State.AIR
		p.can_dash = true
		p.can_double_jump = true
	
	c.velocity = global_transform.basis_xform(Vector2.UP) * impulse_force
	
	if (global_position - Global.player.global_position).length() < 1500.0:
		FmodServer.play_one_shot("event:/Interactables/bounce")
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(
		body_container,
		"scale",
		Vector2(1.2, 0.8),
		0.1
	)
	tween.tween_property(
		body_container,
		"scale",
		Vector2(0.6, 1.4),
		0.1
	)
	tween.tween_property(
		body_container,
		"scale",
		Vector2.ONE,
		0.1
	)

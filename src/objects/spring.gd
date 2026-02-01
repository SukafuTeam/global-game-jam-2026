class_name Spring
extends Area2D

@export var impulse_force: float = 2000.0

var tween: Tween

@onready var body_container: Node2D = $BodyContainer

func _ready() -> void:
	body_entered.connect(on_body_entered)

func on_body_entered(other: Node2D):
	var c = other as CharacterBody2D
	
	c.velocity = global_transform.basis_xform(Vector2.UP) * impulse_force
	
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

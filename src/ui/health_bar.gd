extends TextureRect

@export var health_containers: Array[HealthContainer] = []

var blink_tween: Tween

func _ready():
	Global.player.took_damage.connect(on_player_damage)

func on_player_damage(new_health: int):
	health_containers[new_health].take_damage()
	
	if new_health == 1:
		blink_tween = create_tween()
		blink_tween.set_loops(-1)
		blink_tween.tween_property(self, "modulate", Color.RED, 0.5)
		blink_tween.tween_property(self, "modulate", Color.WHITE, 0.5)
		blink_tween.tween_interval(1.0)
	
	if new_health > 0:
		return
	
	if blink_tween:
		blink_tween.kill()
	
	modulate.a = 0.0
	Global.player.interactible = false
	Global.player.z_index = 1000
	
	Global.camera.limit_enabled = false
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(Global.player.death_filter, "modulate:a", 1.0, 1.0)
	tween.tween_property(Global.camera,"zoom", Vector2.ONE * 2.0, 4.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	await get_tree().create_timer(4.0).timeout
	
	get_tree().change_scene_to_file("res://scenes/menu_scene.tscn")
		
	
	
	
	

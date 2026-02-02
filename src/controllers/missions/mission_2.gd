extends MissionController

@export var wall: TileMapLayer
@export var buttons: Array[PlatformButton] = []

@export var wall_button: PlatformButton
@export var wall_2: StaticBody2D

var finished: bool

func _process(_delta: float) -> void:
	if wall_button.stale:
		if wall_2 != null:
			wall_2.queue_free()
	if finished:
		return
	
	for button in buttons:
		if !button.valid:
			return
	
	finished = true
	FmodServer.play_one_shot("event:/UI/yes")
	wall.queue_free()

extends MissionController

@export var wall: TileMapLayer
@export var buttons: Array[PlatformButton] = []

var finished: bool

func _process(_delta: float) -> void:
	if finished:
		return
	
	for button in buttons:
		if !button.valid:
			return
	
	finished = true
	FmodServer.play_one_shot("event:/UI/yes")
	wall.queue_free()

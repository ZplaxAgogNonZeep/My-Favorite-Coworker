extends Node

var implements = []

# Called when the node enters the scene tree for the first time.
func _ready():
	GameEvents.PauseTimers.connect(pauseTimers)
	GameEvents.UnpauseTimers.connect(unpauseTimers)


func pauseTimers():
	for timer in get_children():
		timer.paused = true


func unpauseTimers():
	for timer in get_children():
		timer.paused = false

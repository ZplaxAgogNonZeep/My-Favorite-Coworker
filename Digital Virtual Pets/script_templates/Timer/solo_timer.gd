extends Timer

func _ready():
	GameEvents.PauseTimers.connect(pauseTimer)
	GameEvents.UnpauseTimers.connect(unpauseTimer)
	GameEvents.PauseGame.connect(pauseTimer)
	GameEvents.UnpauseGame.connect(unpauseTimer)


func pauseTimer():
	paused = true


func unpauseTimer():
	paused = false

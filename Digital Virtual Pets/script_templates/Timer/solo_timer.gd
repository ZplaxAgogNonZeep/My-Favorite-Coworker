extends Timer

func _ready():
	GameEvents.PauseTimers.connect(pauseTimer)
	GameEvents.UnpauseTimers.connect(unpauseTimer)
	GameEvents.PauseGame.connect(pauseTimer)
	GameEvents.UnpauseGame.connect(unpauseTimer)
	GameEvents.ResetAllTimers.connect(stopTimer)


func pauseTimer():
	paused = true


func unpauseTimer():
	paused = false

func stopTimer():
	stop()

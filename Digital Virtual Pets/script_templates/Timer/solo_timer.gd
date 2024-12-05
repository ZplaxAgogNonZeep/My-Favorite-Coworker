extends Timer

func _ready() -> void:
	GameEvents.PauseTimers.connect(pauseTimer)
	GameEvents.UnpauseTimers.connect(unpauseTimer)
	GameEvents.PauseGame.connect(pauseTimer)
	GameEvents.UnpauseGame.connect(unpauseTimer)
	GameEvents.ResetAllTimers.connect(stopTimer)


func pauseTimer() -> void:
	paused = true


func unpauseTimer() -> void:
	paused = false

func stopTimer() -> void:
	stop()

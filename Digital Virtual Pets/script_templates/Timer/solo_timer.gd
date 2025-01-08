extends Timer

func _ready() -> void:
	GameEvents.PauseTimers.connect(_pauseTimer)
	GameEvents.UnpauseTimers.connect(_unpauseTimer)
	GameEvents.PauseGame.connect(_pauseTimer)
	GameEvents.UnpauseGame.connect(_unpauseTimer)
	GameEvents.ResetAllTimers.connect(_stopTimer)





func _pauseTimer() -> void:
	paused = true


func _unpauseTimer() -> void:
	paused = false


func _stopTimer() -> void:
	stop()

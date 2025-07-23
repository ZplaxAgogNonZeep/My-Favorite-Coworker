extends Timer

@export var _useProactivity : bool = true
var _previousTimeScale : float

func _ready() -> void:
	GameEvents.PauseTimers.connect(_pauseTimer)
	GameEvents.UnpauseTimers.connect(_unpauseTimer)
	GameEvents.PauseGame.connect(_pauseTimer)
	GameEvents.UnpauseGame.connect(_unpauseTimer)
	GameEvents.ResetAllTimers.connect(_stopTimer)
	GameEvents.ChangeProactivityMode.connect(_changeProactivity)
	_previousTimeScale = Settings.getTimerMod()


func _changeProactivity():
	if (is_stopped() or !_useProactivity):
		return
	
	var progress = time_left / wait_time
	start((time_left / _previousTimeScale) * Settings.getTimerMod())
	#print(name, ": ", wait_time)
	_previousTimeScale = Settings.getTimerMod()


func _pauseTimer() -> void:
	paused = true


func _unpauseTimer() -> void:
	paused = false


func _stopTimer() -> void:
	stop()

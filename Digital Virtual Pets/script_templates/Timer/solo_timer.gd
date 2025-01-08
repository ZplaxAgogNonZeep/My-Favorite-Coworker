extends Timer

@export var _useProactivity : bool = true

func _ready() -> void:
	GameEvents.PauseTimers.connect(_pauseTimer)
	GameEvents.UnpauseTimers.connect(_unpauseTimer)
	GameEvents.PauseGame.connect(_pauseTimer)
	GameEvents.UnpauseGame.connect(_unpauseTimer)
	GameEvents.ResetAllTimers.connect(_stopTimer)
	GameEvents.ChangeProactivityMode.connect(_changeProactivity)


func _changeProactivity(isProactive: bool):
	if (is_stopped() or not _useProactivity):
		return
	
	var progress = time_left / wait_time
	var debug = wait_time
	
	if (isProactive):
		start( lerpf(0,wait_time * Settings.getTimerMod(), progress))
	else:
		start(lerpf(0, (wait_time / (Settings.proactivityTimeModifier * 100)) * 100, progress))
	
	print(name, " has changed time to ", time_left)


func _pauseTimer() -> void:
	paused = true


func _unpauseTimer() -> void:
	paused = false


func _stopTimer() -> void:
	stop()

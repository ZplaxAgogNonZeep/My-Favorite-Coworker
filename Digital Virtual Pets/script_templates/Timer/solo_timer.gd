extends Timer

@export var _useProactivity : bool = true

func _ready() -> void:
	GameEvents.PauseTimers.connect(_pauseTimer)
	GameEvents.UnpauseTimers.connect(_unpauseTimer)
	GameEvents.PauseGame.connect(_pauseTimer)
	GameEvents.UnpauseGame.connect(_unpauseTimer)
	GameEvents.ResetAllTimers.connect(_stopTimer)
	GameEvents.ChangeProactivityMode.connect(_changeProactivity)


func _changeProactivity():
	#TODO: HEY FIX THISSSSSSSSSSS
	pass
	#if (is_stopped()):
		#return
	#
	#var progress = time_left / wait_time
	#
	#if (isProactive):
		#start( lerpf(0,wait_time * Settings.getTimerMod(), progress))
	#else:
		#start(lerpf(0, (wait_time / (Settings.proactivityTimeModifier * 100)) * 100, progress))
	


func _pauseTimer() -> void:
	paused = true


func _unpauseTimer() -> void:
	paused = false


func _stopTimer() -> void:
	stop()

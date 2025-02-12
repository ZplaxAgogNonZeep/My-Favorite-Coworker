extends Node

class_name settings

enum WindowAttentionOptions {BRING_TO_FRONT, ALWAYS_ON_TOP, DO_NOT_CHANGE}

func _ready() -> void:
	get_tree().call_group("Debug", "debugReady")

#region Global Variables
var windowFocused : bool = true
var proactiveMode : bool = false
#endregion

#region Settings Variables
##  Bools
var isUsingProactivity := true
var isSetWindowPinned := false
var isRequestAttentionAllowed := true
## Floats
var proactivityTimeModifier := 0.50
#endregion

func pauseGame(isPaused : bool):
	if (get_tree().paused == isPaused):
		return
	
	get_tree().paused = isPaused
	
	if (get_tree().paused):
		GameEvents.PauseGame.emit()
	else:
		GameEvents.UnpauseGame.emit()

#region User Settings Functions
func setProactivitySetting(isTrue : bool):
	isUsingProactivity = isTrue


func setBorderless(isBorderless : bool):
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, isBorderless)
#endregion

#region Getter & Setter Functions
func getTimerMod() -> float:
	if !proactiveMode:
		return 1
	else:
		return proactivityTimeModifier

func setProactivityMode(isProactive : bool):
	proactiveMode = isProactive
	GameEvents.ChangeProactivityMode.emit(proactiveMode)

#endregion

#region Helper Functions


#endregion

extends Node

class_name settings

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

#region Getter & Setter Functions

## Variable Setters
func setProactivityMode(isProactive : bool):
	proactiveMode = isProactive
	GameEvents.ChangeProactivityMode.emit(proactiveMode)

## Options Setters
func setProactivitySetting(isTrue : bool):
	isUsingProactivity = isTrue

func getTimerMod() -> float:
	if !proactiveMode:
		return 1
	else:
		return proactivityTimeModifier

#endregion

#region Helper Functions


#endregion

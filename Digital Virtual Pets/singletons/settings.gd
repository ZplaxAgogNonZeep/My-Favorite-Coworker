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
## Floats
var proactivityTimeModifier := 0.50
#endregion


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

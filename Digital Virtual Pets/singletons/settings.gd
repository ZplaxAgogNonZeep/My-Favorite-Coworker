extends Node

class_name settings

enum WindowAttentionOptions {BRING_TO_FRONT, ALWAYS_ON_TOP, DO_NOT_CHANGE}

func _ready() -> void:
	get_tree().call_group("Debug", "debugReady")

#region Global Variables
var windowFocused : bool = true
var proactiveMode : bool = false
var borderless : bool = true
#endregion

#region Settings Variables
##  Bools
var isUsingProactivity := true
var isSetWindowPinned := false
var isRequestAttentionAllowed := true
## Floats
var proactivityTimeModifier := 0.50
## Ints
#TODO: Make sure this is implemented and the definitive way to check game scale
var gameScale := 2
## Enums
var windowAttentionMode : WindowAttentionOptions = WindowAttentionOptions.BRING_TO_FRONT
#endregion

func pauseGame(isPaused : bool):
	if (get_tree().paused == isPaused):
		return
	
	get_tree().paused = isPaused
	
	if (get_tree().paused):
		GameEvents.PauseGame.emit()
	else:
		GameEvents.UnpauseGame.emit()

## Update this function here when making save data!
func saveSettings():
	var settingsDict = {
		"isUsingProactivity" : isUsingProactivity,
		"isSetWindowPinned" : isSetWindowPinned,
		"isRequestAttentionAllowed" : isRequestAttentionAllowed,
		"windowAttentionMode" : windowAttentionMode
	}
	
	SaveData.saveSettingsToFile(settingsDict)

#region User Settings Functions
func setProactivitySetting(isTrue : bool):
	if (isUsingProactivity == isTrue):
		return
	
	isUsingProactivity = isTrue
	if (!isUsingProactivity):
		GameEvents.ChangeProactivityMode.emit(true)


func setWindowAttentionMode(windowAttention : WindowAttentionOptions):
	windowAttentionMode = windowAttention


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

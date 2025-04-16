extends Node

class_name settings

enum WindowOrientationOptions {TOP_LEFT_CORNER, TOP_RIGHT_CORNER, BOT_LEFT_CORNER, BOT_RIGHT_CORNER, CUSTOM}
enum WindowAttentionOptions {BRING_TO_FRONT, ALWAYS_ON_TOP, DO_NOT_CHANGE}

	

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
#TODO: Frame Rate Limit
#TODO: Make sure this is implemented and the definitive way to check game scale
var gameScale := 2
## Vectors
var _lastWindowPosn := Vector2i.ZERO
var _defaultWindowSize : Vector2i
## Enums
var windowAttentionMode : WindowAttentionOptions = WindowAttentionOptions.BRING_TO_FRONT
var windowOrientation : WindowOrientationOptions = WindowOrientationOptions.BOT_RIGHT_CORNER
#endregion

func _ready() -> void:
	get_tree().call_group("Debug", "debugReady")
	setWindowPosition()
	_defaultWindowSize = get_viewport().get_window().size


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

#endregion

#region Window Functions

func setBorderless(isBorderless : bool):
	borderless = isBorderless
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, isBorderless)


func toggleMinimizedWindow(isMinimized : bool):
	if (isMinimized):
		get_viewport().get_window().size /= 3
		GameEvents.ChangeCameraZoom.emit(3, (_defaultWindowSize / 3) * 2 )
		setWindowPosition()
	else:
		get_viewport().get_window().size = _defaultWindowSize
		GameEvents.ChangeCameraZoom.emit(1, Vector2.ZERO)
		setWindowPosition()


func setWindowPosition():
	var newPosn = Vector2i.ZERO
	if (windowOrientation == WindowOrientationOptions.CUSTOM):
		newPosn = _lastWindowPosn
	
	var screenSize = DisplayServer.screen_get_usable_rect().size
	var gameWindowSize = get_viewport().get_window().size
	
	match windowOrientation:
		WindowOrientationOptions.BOT_RIGHT_CORNER:
			newPosn = Vector2i(screenSize.x - gameWindowSize.x, screenSize.y - gameWindowSize.y)
		WindowOrientationOptions.TOP_LEFT_CORNER:
			newPosn = Vector2i(0, 0)
		WindowOrientationOptions.TOP_RIGHT_CORNER:
			newPosn = Vector2i(screenSize.x - gameWindowSize.x, 0)
		WindowOrientationOptions.BOT_LEFT_CORNER:
			newPosn = Vector2i(0, screenSize.y - gameWindowSize.y)
	
	get_viewport().get_window().position = newPosn

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

func determineDeviceGrowDir() -> int:
	match windowOrientation:
		WindowOrientationOptions.CUSTOM:
			return 0
		WindowOrientationOptions.TOP_LEFT_CORNER:
			return -1
		WindowOrientationOptions.BOT_LEFT_CORNER:
			return -1
		WindowOrientationOptions.TOP_RIGHT_CORNER:
			return 1
		WindowOrientationOptions.BOT_RIGHT_CORNER:
			return 1
		_:
			return 0
#endregion

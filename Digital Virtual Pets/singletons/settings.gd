extends Node

class_name settings

enum WindowOrientationOptions {TOP_LEFT_CORNER, TOP_RIGHT_CORNER, BOT_LEFT_CORNER, BOT_RIGHT_CORNER, CUSTOM}
enum WindowAttentionOptions {BRING_TO_FRONT, ALWAYS_ON_TOP, DO_NOT_CHANGE}

	

#region Observation Variables
# These variables are meant to make it easy to track certain OS states
var windowFocused : bool = true
var proactiveMode : bool = false
var borderless : bool = true
var activeMonitor : int = 1
#endregion

#region Settings Variables
# These variables represent the player's preferences of variables
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
var _customWindowPosn := Vector2i.ZERO
var _defaultWindowSize : Vector2i
## Enums
var windowAttentionMode : WindowAttentionOptions = WindowAttentionOptions.BRING_TO_FRONT
var windowOrientation : WindowOrientationOptions = WindowOrientationOptions.BOT_RIGHT_CORNER
#endregion

func _ready() -> void:
	get_tree().call_group("Debug", "debugReady")
	activeMonitor = DisplayServer.window_get_current_screen()
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

## Changes the active monitor to [param monitorIndex], then moves the game window over to
## be in corresponding position. If the Custom option is set for the [enum WindowOrientation], 
## it will default to the same proportional position.
func changeActiveMonitor(monitorIndex : int) -> void:
	if (activeMonitor == monitorIndex or monitorIndex >= DisplayServer.get_screen_count()):
		return
	var oldWindowIndex = activeMonitor
	DisplayServer.window_set_current_screen(monitorIndex)
	activeMonitor = monitorIndex
	
	if (windowOrientation == WindowOrientationOptions.CUSTOM):
		_customWindowPosn = _convertPositionBetweenResolutions(_customWindowPosn, 
										DisplayServer.screen_get_usable_rect(oldWindowIndex).position,
										DisplayServer.screen_get_usable_rect(monitorIndex).position)
	
	#print(DisplayServer.window_get_position())
	setWindowPosition()


func toggleMinimizedWindow(isMinimized : bool):
	if (isMinimized):
		get_viewport().get_window().size /= 3
		GameEvents.ChangeCameraZoom.emit(3, floor((_defaultWindowSize / 3)) * 2)
		setWindowPosition()
	else:
		get_viewport().get_window().size = _defaultWindowSize
		GameEvents.ChangeCameraZoom.emit(1, Vector2.ZERO)
		setWindowPosition()


func setWindowPosition():
	var newPosn = Vector2i.ZERO
	if (windowOrientation == WindowOrientationOptions.CUSTOM):
		newPosn = _customWindowPosn
	
	#var monitorOffset
	#if (activeMonitor != DisplayServer.get_primary_screen()):
		
	var screenSize = DisplayServer.screen_get_usable_rect(activeMonitor).size
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
	
	get_viewport().get_window().position = DisplayServer.screen_get_position(activeMonitor) + newPosn

#endregion

#region Getter & Setter Functions
func getTimerMod() -> float:
	if !proactiveMode:
		return 1
	else:
		return proactivityTimeModifier


func getMonitorCount() -> int:
	return DisplayServer.get_screen_count()


func getPrimaryMonitor() -> int:
	return DisplayServer.get_primary_screen()


func setProactivityMode(isProactive : bool):
	proactiveMode = isProactive
	GameEvents.ChangeProactivityMode.emit(proactiveMode)


func setBorderless(isBorderless : bool) -> void:
	borderless = isBorderless
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, isBorderless)


func setWindowOrientation(option : WindowOrientationOptions) -> void:
	windowOrientation = option
	setWindowPosition()

#endregion

#region Helper Functions
## Decides which direction the device should shrink and grow to based on 
## [enum WindowOrientation].
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

## Converts [param screenPosn] proportionally from two screen resolutions.
func _convertPositionBetweenResolutions(screenPosn : Vector2i, 
									resolutionFrom : Vector2i, resolutionTo : Vector2i) -> Vector2i:
	return Vector2i(lerp(0, resolutionTo.x, screenPosn.x / resolutionFrom.x), 
					lerp(0, resolutionTo.y, screenPosn.y / resolutionFrom.y))




#endregion

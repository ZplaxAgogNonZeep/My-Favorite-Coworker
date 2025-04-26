extends Node

class_name settings

enum WindowOrientationOptions {TOP_LEFT_CORNER, TOP_RIGHT_CORNER, BOT_LEFT_CORNER, BOT_RIGHT_CORNER, CUSTOM}
enum WindowAttentionOptions {BRING_TO_FRONT, ALWAYS_ON_TOP, DO_NOT_CHANGE}
enum SubWindowPositionType {MANAGER_WINDOW, MANAGED_WINDOW}



#region Observation Variables
# These variables are meant to make it easy to track certain OS states
var windowFocused : bool = true
var proactiveMode : bool = false
var borderless : bool = true
var activeMonitor : int = 0
var _activeWindows : Array[Window]
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
var monitorSetTo := 0
## Vectors
var _customWindowPosn := Vector2i.ZERO
var _defaultWindowSize : Vector2i
## Enums
var windowAttentionMode : WindowAttentionOptions = WindowAttentionOptions.BRING_TO_FRONT
var windowOrientation : WindowOrientationOptions = WindowOrientationOptions.BOT_RIGHT_CORNER
#endregion

func _ready() -> void:
	# This is the last ready function to be called before the all the normal scene nodes call it
	# so anything that needs to be changed to match settings like window position needs to be done 
	# here
	activeMonitor = DisplayServer.window_get_current_screen()
	if (monitorSetTo != activeMonitor):
		changeActiveMonitor(monitorSetTo)
	setWindowPosition()
	setWindowAttentionMode(windowAttentionMode)
	
	_defaultWindowSize = get_viewport().get_window().size
	get_tree().call_group("Debug", "debugReady")


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
		"windowAttentionMode" : windowAttentionMode,
		"windowOrientation" : windowOrientation,
		"monitorSetTo" : monitorSetTo
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
	
	match windowAttentionMode:
		WindowAttentionOptions.ALWAYS_ON_TOP:
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true)
		WindowAttentionOptions.BRING_TO_FRONT:
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, false)
		WindowAttentionOptions.DO_NOT_CHANGE:
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, false)
	
	for window in _activeWindows:
		match windowAttentionMode:
			WindowAttentionOptions.ALWAYS_ON_TOP:
				window.always_on_top = true
			WindowAttentionOptions.BRING_TO_FRONT:
				window.always_on_top = false
			WindowAttentionOptions.DO_NOT_CHANGE:
				window.always_on_top = false
		window.resetWindow()

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
	
	setWindowPosition()


## Makes the window smaller to account for a minimized device
func toggleMinimizedWindow(isMinimized : bool):
	if (isMinimized):
		get_viewport().get_window().size /= 3
		GameEvents.ChangeCameraZoom.emit(3, floor((_defaultWindowSize / 3)) * 2)
		setWindowPosition()
	else:
		get_viewport().get_window().size = _defaultWindowSize
		GameEvents.ChangeCameraZoom.emit(1, Vector2.ZERO)
		setWindowPosition()


## Updates the main game window's position to either match the anchor of the monitor it's on
## or to be in the porportional same position if set to custom.
func setWindowPosition() -> void:
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


## Takes [param windowPositionType] and a [param windowSize] to find a valid screen position 
## to place a new window in. Default position scaling direction should be up and to the left.
func findValidWindowPosition(windowPositionType : SubWindowPositionType, windowSize : Vector2i):
	var buildDir = Vector2i.ZERO
	var gameWindowSize = get_viewport().get_window().size
	var gameWindowPosition = get_viewport().get_window().position
	var resolution = DisplayServer.screen_get_usable_rect(activeMonitor).size
	var offset : Vector2i = (gameWindowSize * .5) - (windowSize * .5)
	var finalWindowPosition = Vector2i.ZERO
	
	match windowOrientation:
		WindowOrientationOptions.TOP_LEFT_CORNER:
			buildDir = Vector2i(1, 1)
		WindowOrientationOptions.TOP_RIGHT_CORNER:
			buildDir = Vector2i(-1, 1)
		WindowOrientationOptions.BOT_LEFT_CORNER:
			buildDir = Vector2i(1, -1)
		WindowOrientationOptions.BOT_RIGHT_CORNER:
			buildDir = Vector2i(-1, -1)
		WindowOrientationOptions.CUSTOM:
			# Check for the quadrant the window is in
			pass
	
	var managerPosn = Vector2i(int((windowSize.x * .5) * buildDir.x), 0)
	
	if (windowPositionType == SubWindowPositionType.MANAGER_WINDOW):
		# The manager window should appear just to the side of the device
		finalWindowPosition = managerPosn + offset
	elif (windowPositionType == SubWindowPositionType.MANAGED_WINDOW):
		# The managed windows should appear in a random space past the manager window
		# bounds are vectors where x is the origin point and y is extended out from there
		# Bounds will be used to determine a minimum and maximum range for RNG selection
		var xBounds : Vector2i
		xBounds.x = 0
		xBounds.y = (windowSize.x * 1) * buildDir.x
		if (!_checkWhithinRange(((xBounds.x + offset.x) + gameWindowPosition.x) + 
																	(windowSize.x * buildDir.x * -1), 
								Vector2i(0, resolution.x))):
			xBounds.x += (windowSize.x * .5) * buildDir.x
		
		var yBounds : Vector2i
		yBounds.x = (windowSize.y) * buildDir.y
		yBounds.y = (windowSize.y) * buildDir.y
		
		if (!_checkWhithinRange(((yBounds.x + offset.y) + gameWindowPosition.y) + 
								(windowSize.y * buildDir.y * -1), 
									Vector2i(0, resolution.y))):
			yBounds.x += (windowSize.y * .5) * buildDir.y
		
		var min : Vector2i
		var max : Vector2i
		if xBounds.x > xBounds.y:
			min.x = xBounds.y
			max.x = xBounds.x
		else:
			max.x = xBounds.y
			min.x = xBounds.x
		
		if yBounds.x > yBounds.y:
			min.y = yBounds.y
			max.y = yBounds.x
		else:
			max.y = yBounds.y
			min.y = yBounds.x
		
		finalWindowPosition = Vector2i(randi_range(min.x, max.x), randi_range(min.y, max.y)) + offset
	return gameWindowPosition + finalWindowPosition

func addToActiveWindows(window : Window):
	if (!_activeWindows.has(window)):
		_activeWindows.append(window)

func removeFromActiveWindows(window : Window):
	_activeWindows.erase(window)

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
	for window in _activeWindows:
		window.resetWindow()

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


## Takes a [param point] within a single axis and returns if it falls inside that range.
func _checkWhithinRange(point : float, resolution : Vector2) -> bool:
	return point >= resolution.x and point <= resolution.y

#endregion

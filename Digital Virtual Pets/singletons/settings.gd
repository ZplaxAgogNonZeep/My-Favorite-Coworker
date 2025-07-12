extends Node

class_name settings

enum WindowOrientationOptions {TOP_LEFT_CORNER, TOP_RIGHT_CORNER, BOT_LEFT_CORNER, BOT_RIGHT_CORNER, CUSTOM}
enum WindowAttentionOptions {BRING_TO_FRONT, ALWAYS_ON_TOP, DO_NOT_CHANGE}
enum SubWindowPositionType {MANAGER_WINDOW, MANAGED_WINDOW, DIALOG}



#region Observation Variables
# These variables are meant to make it easy to track certain OS states
var windowFocused : bool = true
var proactiveMode : bool = false
var borderless : bool = true
var activeMonitor : int = 0
var _activeWindows : Array[Window]
var minimized : bool
#endregion

#region Settings Variables
# These variables represent the player's preferences of variables
##  Bools
var isUsingProactivity := true
var isRequestAttentionAllowed := true
## Floats
var proactivityTimeModifier := 0.50
var masterVolume : float = .5
var deviceVolume : float = 1.0
var gameVolume : float = 1.0
## Ints
#TODO: Make sure this is implemented and the definitive way to check game scale
var gameScale := 2
var monitorSetTo := 0
var frameCapSetTo := 60
## Vectors
var _customWindowPosn := Vector2i.ZERO
var _defaultWindowSize : Vector2i = Vector2i(128, 160)
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
	setFrameCap(frameCapSetTo)
	setVolume(SfxManager.BusType.MASTER, masterVolume)
	setVolume(SfxManager.BusType.GAME, gameVolume)
	setVolume(SfxManager.BusType.DEVICE, deviceVolume)
	if (!SaveData.isSaveDataExists(true)):
		if (Settings.getMonitorResolution().size.x > 2000 and Settings.getMonitorResolution().size.y > 1200):
			gameScale = 4
	changeGameScale(gameScale)
	
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
		"isRequestAttentionAllowed" : isRequestAttentionAllowed,
		"windowAttentionMode" : windowAttentionMode,
		"windowOrientation" : windowOrientation,
		"monitorSetTo" : monitorSetTo,
		"frameCapSetTo" : frameCapSetTo,
		"masterVolume" : masterVolume,
		"deviceVolume" : deviceVolume,
		"gameVolume" : gameVolume,
		"gameScale" : gameScale
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
	
	var dupeArray = _activeWindows.duplicate(true)
	for window in dupeArray:
		match windowAttentionMode:
			WindowAttentionOptions.ALWAYS_ON_TOP:
				window.always_on_top = true
			WindowAttentionOptions.BRING_TO_FRONT:
				window.always_on_top = false
			WindowAttentionOptions.DO_NOT_CHANGE:
				window.always_on_top = false
		window.resetWindow()


func setVolume(bus : SfxManager.BusType, value : float):
	match bus:
		SfxManager.BusType.MASTER:
			masterVolume = value
		SfxManager.BusType.DEVICE:
			deviceVolume = value
		SfxManager.BusType.GAME:
			gameVolume = value
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))


func setFrameCap(frameCap : int):
	Engine.max_fps = frameCap
	frameCapSetTo = frameCap


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

## Adjusts the variable for the overall scaling of the game. This has wide game ranging applications
## so it's important that this is called instead of manually changing it.
func changeGameScale(newScale : int):
	gameScale = newScale
	get_viewport().get_window().size = _defaultWindowSize * gameScale
	#GameEvents.ChangeCameraZoom.emit(1 - (.25 * (gameScale - 2)), Vector2.ZERO)
	#GameEvents.ChangeGameScale.emit(gameScale)
	setWindowPosition()

## Makes the window smaller to account for a minimized device
func toggleMinimizedWindow(isMinimized : bool):
	if (isMinimized):
		get_viewport().get_window().size = Vector2i((_defaultWindowSize * 2) / 3)
		GameEvents.ChangeCameraZoom.emit(3, floor(((_defaultWindowSize * 2) / 3)) * 2)
		setWindowPosition()
	else:
		await get_tree().process_frame
		get_viewport().get_window().size = _defaultWindowSize * gameScale
		GameEvents.ChangeCameraZoom.emit(1, Vector2.ZERO)
		setWindowPosition()


## Takes a game request for attention and decide what to do based on the settings.
func requestPlayerAttention():
	if (not Settings.isRequestAttentionAllowed):
		return
	match windowAttentionMode:
		WindowAttentionOptions.BRING_TO_FRONT:
			DisplayServer.window_request_attention()
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, false)
		WindowAttentionOptions.ALWAYS_ON_TOP:
			DisplayServer.window_request_attention()
		WindowAttentionOptions.DO_NOT_CHANGE:
			DisplayServer.window_request_attention()
	
	if (minimized):
		GameEvents.DeviceRequestAttention.emit()
		await GameEvents.DeviceAttentionReceived
	
	return
	#if (Settings.isSetWindowPinned):
		#DisplayServer.window_request_attention()
	#else:
		#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true)
		#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, false)


## Updates the main game window's position to either match the anchor of the monitor it's on
## or to be in the porportional same position if set to custom.
func setWindowPosition(overrideWindowSize : Vector2i = Vector2i.ZERO) -> void:
	var newPosn = Vector2i.ZERO
	if (windowOrientation == WindowOrientationOptions.CUSTOM):
		newPosn = _customWindowPosn
	
	#var monitorOffset
	#if (activeMonitor != DisplayServer.get_primary_screen()):
	
	var screenSize = DisplayServer.screen_get_usable_rect(activeMonitor).size
	var gameWindowSize = get_viewport().get_window().size
	if (overrideWindowSize != Vector2i.ZERO):
		gameWindowSize = overrideWindowSize
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
func findValidWindowPosition(windowPositionType : SubWindowPositionType, windowSize : Vector2i, 
							originPosn := Vector2i.ZERO) -> Vector2i:
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
	elif (windowPositionType == SubWindowPositionType.DIALOG):
		# Dialog windows are a special case where we want to designate a spot ahead of time, then
		# figure out a variance for it. originPosn should be an offsetted position relative to the
		# center of the device
		var windowOrigin = originPosn + offset
		var xBounds : Vector2i
		xBounds.y = (windowSize.x * .5) * buildDir.x
		if (_checkWhithinRange((windowOrigin.x + gameWindowPosition.x) + 
													((windowSize.x * .5) * buildDir.x * -1), 
								Vector2i(0, resolution.x))):
			xBounds.x = windowOrigin.x
		
		var yBounds : Vector2i
		yBounds.x = (gameWindowSize.y * .5 + originPosn.y) - (windowSize.y * 2)
		yBounds.y = (gameWindowSize.y * .5 + originPosn.y) - (windowSize.y * .5)
		
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
		
		var randomPosn = Vector2i(randi_range(min.x, max.x), randi_range(min.y, max.y))
		#var randomPosn = Vector2i(max.x, max.y)
		finalWindowPosition = randomPosn + offset
		pass
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


func getMonitorResolution(monitorIndex := -1) -> Rect2i:
	var monitor
	if (monitorIndex == -1):
		monitor = DisplayServer.screen_get_usable_rect(activeMonitor)
	else:
		monitor = DisplayServer.screen_get_usable_rect(monitorIndex)
	
	return monitor


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
	var dupeArray = _activeWindows.duplicate(true)
	for window in dupeArray:
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

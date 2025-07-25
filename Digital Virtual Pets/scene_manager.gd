extends Node2D

class DataSaver extends SaveData.DataSaver:
	func getCategoryName():
		return "SceneManager"
	var _firstTimeOpened

@export_category("Node References")
@export var _camera : Camera2D
@export var _menuManager : MenuManager
@export var _iconMenu : Menu
@export var _background : Control
@export var device : Device
@export var _shadow : Sprite2D
@export var _tutorialDialog : CharacterDialog
@export var _cutsceneAnimationPlayer : AnimationPlayer

var _windowPosition : Vector2
var _firstTimeOpened := true

var _recordingMode := false ## DEBUG ONLY. Hard Coded variable that makes getting gameplay footage easier

func _ready() -> void:
	GameEvents.OpenOptionsMenu.connect(_openMenu)
	GameEvents.ChangeCameraZoom.connect(_changeCameraZoom)
	GameEvents.ChangeGameScale.connect(_onChangeGameScale)
	
	# This is where the game officially starts, remember that it happens AFTER every ready function
	device.visible = false
	if (_shadow):
		_shadow.visible = false
	if (_recordingMode):
		return
	if (_firstTimeOpened):
		#if (Settings.getMonitorResolution().size.x > 2000 and Settings.getMonitorResolution().size.y > 1200):
			#Settings.changeGameScale(4)
		await get_tree().create_timer(1).timeout
		GameEvents.DisplayDialog.emit(Vector2i(-999,-999), _tutorialDialog, 
						"New Game Dialog", Callable(self, "_newGameCutsceneFinished"))
	else:
		_displayDevice(true)


func _process(delta: float) -> void:
	_proactivityBehavior()


func _input(event: InputEvent) -> void:
	#if !_recordingMode:
		#return
	pass
	#if event.is_action_pressed("Debug"):
		#GameEvents.DisplayDialog.emit(Vector2i(0,0), _tutorialDialog, 
					#"Device Tutorial", Callable(self, "_deviceTutorialFinished"))
	#if event.is_action_pressed("Debug2"):
		##Settings.setBorderless(!Settings.borderless)
		##SfxManager.playMusic(_testSound)
		##await get_tree().create_timer(5).timeout
		##SfxManager.incrementMusic(1)
		#pass
	#if (Input.is_action_just_pressed("Debug3")):
		#GameEvents.EvolveCheck.emit()


func _displayDevice(skipAnimation := false):
	if (skipAnimation):
		device.visible = true
		if (_shadow):
			_shadow.visible = true
		device.turnOnDevice()
		return
	
	_cutsceneAnimationPlayer.play("device_spawn")
	await get_tree().process_frame
	device.visible = true
	if (_shadow):
		_shadow.visible = true
	
	await _cutsceneAnimationPlayer.animation_finished
	device.turnOnDevice()
	
	if (_recordingMode):
		return
	await get_tree().create_timer(1)
	GameEvents.DisplayDialog.emit(Vector2i(0,0), _tutorialDialog, 
					"Device Tutorial", Callable(self, "_deviceTutorialFinished"))


func _openMenu():
	_menuManager.toggleMenu(true)


#region Window Events

func _proactivityBehavior():
	#if (!Settings.isUsingProactivity):
		#return
	
	Settings.windowFocused = DisplayServer.window_is_focused()
	
	#if (Settings.windowFocused and Settings.proactiveMode):
		#Settings.setProactivityMode(false)
	#elif (not Settings.windowFocused and not Settings.proactiveMode):
		#Settings.setProactivityMode(true)


func _onChangeGameScale(scale : int):
	device.scale = Vector2(scale, scale)
	device.position.x = get_viewport().get_window().size.x * .5
	device.position.y = get_viewport().get_window().size.y - (12 * Settings.gameScale)


func _changeCameraZoom(_scale : float, _position : Vector2):
	#_shadow.visible = _scale == 1
	_camera.zoom = Vector2(_scale, _scale)
	_camera.position = _position
#endregion



#region Cutscene Routines
func _newGameCutsceneFinished(threadHistory : Array):
	_firstTimeOpened = false
	GameEvents.UnlockNewEgg.emit(load(PetManager.EGG_DATA_PATH + "buh_egg.tres"))
	SaveData.saveGameToFile()
	_displayDevice()


func _deviceTutorialFinished(threadHistory : Array):
	pass

#endregion

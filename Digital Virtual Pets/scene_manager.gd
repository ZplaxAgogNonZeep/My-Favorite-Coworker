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

func _ready() -> void:
	GameEvents.OpenOptionsMenu.connect(_openMenu)
	GameEvents.ChangeCameraZoom.connect(_changeCameraZoom)
	Engine.max_fps = 60
	
	# This is where the game officially starts, remember that it happens AFTER every ready function
	device.visible = false
	_shadow.visible = false
	if (_firstTimeOpened):
		await get_tree().create_timer(1).timeout
		GameEvents.DisplayDialog.emit(Vector2i(-999,-999), _tutorialDialog, 
						"New Game Dialog", Callable(self, "_newGameCutsceneFinished"))
	else:
		_displayDevice(true)


func _process(delta: float) -> void:
	_proactivityBehavior()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Debug2"):
		pass


func _displayDevice(skipAnimation := false):
	if (skipAnimation):
		device.visible = true
		_shadow.visible = true
		device.turnOnDevice()
		return
	
	_cutsceneAnimationPlayer.play("device_spawn")
	await get_tree().process_frame
	device.visible = true
	_shadow.visible = true
	
	await _cutsceneAnimationPlayer.animation_finished
	device.turnOnDevice()
	
	await get_tree().create_timer(1)
	GameEvents.DisplayDialog.emit(Vector2i(0,0), _tutorialDialog, 
					"Device Tutorial", Callable(self, "_deviceTutorialFinished"))


func _openMenu():
	_menuManager.toggleMenu(true)


#region Window Events

func _proactivityBehavior():
	if (!Settings.isUsingProactivity):
		return
	
	Settings.windowFocused = DisplayServer.window_is_focused()
	
	if (Settings.windowFocused and Settings.proactiveMode):
		Settings.setProactivityMode(false)
	elif (not Settings.windowFocused and not Settings.proactiveMode):
		Settings.setProactivityMode(true)




func _changeCameraZoom(_scale : float, _position : Vector2):
	_camera.zoom = Vector2(_scale, _scale)
	_camera.position = _position
#endregion



#region Cutscene Routines
func _newGameCutsceneFinished(threadHistory : Array):
	_firstTimeOpened = false
	SaveData.saveGameToFile()
	_displayDevice()


func _deviceTutorialFinished(threadHistory : Array):
	pass

#endregion

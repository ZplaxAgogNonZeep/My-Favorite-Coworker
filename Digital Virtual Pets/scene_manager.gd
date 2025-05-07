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
@export var _test : CharacterDialog
@export var _testSound : SoundGroup

var _windowPosition : Vector2
var _firstTimeOpened := true

func _ready() -> void:
	GameEvents.OpenOptionsMenu.connect(_openMenu)
	GameEvents.ChangeCameraZoom.connect(_changeCameraZoom)
	Engine.max_fps = 60
	
	# This is where the game officially starts, remember that it happens AFTER every ready function
	device.visible = false
	if (_firstTimeOpened):
		GameEvents.DisplayDialog.emit(Vector2i(1,1), _test, 
						"New Game Dialog", Callable(self, "firstOpenReturned"))
	else:
		_displayDevice(true)
	
	
	#device.turnOnDevice()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Debug2"):
		pass
		SfxManager.playSoundEffect(_testSound)
		#GameEvents.DisplayDialog.emit(Vector2i(-999, -999), _test, 
						#"Device Tutorial", Callable(self, "firstOpenReturned"))


func _displayDevice(skipAnimation := false):
	if (skipAnimation):
		device.visible = true
		device.turnOnDevice()
		return
	
	device.spawnDevice()
	await get_tree().process_frame
	device.visible = true


func _openMenu():
	_menuManager.toggleMenu(true)



func _changeCameraZoom(_scale : float, _position : Vector2):
	_camera.zoom = Vector2(_scale, _scale)
	_camera.position = _position


#region Dialog Control Functions
func firstOpenReturned(threadHistory : Array):
	_firstTimeOpened = false
	SaveData.saveGameToFile()
	_displayDevice()

#endregion

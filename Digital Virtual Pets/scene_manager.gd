extends Node2D

class DataSaver extends SaveData.DataSaver:
	func getCategoryName():
		return "SceneManager"
	var _firstTimeOpened
	

@export_category("Node References")
@export var _menuManager : MenuManager
@export var _iconMenu : Menu
@export var _background : Control
@export var device : Device
@export var _test : CharacterDialog

var _windowPosition : Vector2
var _firstTimeOpened := true

func _ready() -> void:
	# This is where the game officially starts, remember that it happens AFTER every ready function
	if (_firstTimeOpened):
		pass
	else:
		pass
	
	device.turnOnDevice()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Debug2"):
		GameEvents.DisplayDialog.emit(Vector2(300, 250), _test, 
						"New Game Dialog", Callable(self, "testReturnFunction"))
						
		GameEvents.DisplayDialog.emit(Vector2(150, 100), _test, 
						"New Game Dialog", Callable(self, "testReturnFunction"))
		
		GameEvents.DisplayDialog.emit(Vector2(350, 500), _test, 
						"New Game Dialog", Callable(self, "testReturnFunction"))
	
	if (event is InputEventMouseButton):
		if (event.double_click and _menuManager.isMenuOpen() and _iconMenu == _menuManager.getActiveMenu()):
			_menuManager.toggleMenu(false)
			get_tree().create_tween().tween_property(_background, "modulate", Color(Color.WHITE, 0.0), .75)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		elif (event.double_click and not _menuManager.isMenuOpen()):
			_menuManager.toggleMenu(true)
			get_tree().create_tween().tween_property(_background, "modulate", Color(Color.WHITE, 1), .75)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)


func testReturnFunction(threadHistory : Array):
	print("Return Function works!")
	

func createDevice():
	pass

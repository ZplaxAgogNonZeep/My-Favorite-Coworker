extends Node2D

@export_category("Node References")
@export var _menuManager : MenuManager
@export var _iconMenu : Menu
@export var _background : Control

var testClass : TestINGBABY

class TestINGBABY:
	var testint : int = 5
	var testbool : bool = true
	var testDict : Dictionary = {"doot":1, "doot2":2}
	var testArray : Array = [1,2,3,4,5,6]
	var testResource : Resource

class DataSaver extends SaveData.DataSaver:
	func getCategoryName():
		return "TestClass"
	
	var testClass: TestINGBABY

func _ready() -> void:
	SaveData.loadGameFromFile()
	print(testClass)
	#SaveData.saveGameToFile()

func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton):
		if (event.double_click and _menuManager.isMenuOpen() and _iconMenu == _menuManager.getActiveMenu()):
			_menuManager.toggleMenu(false)
			get_tree().create_tween().tween_property(_background, "modulate", Color(Color.WHITE, 0.0), .75)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		elif (event.double_click and not _menuManager.isMenuOpen()):
			_menuManager.toggleMenu(true)
			get_tree().create_tween().tween_property(_background, "modulate", Color(Color.WHITE, 1), .75)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)

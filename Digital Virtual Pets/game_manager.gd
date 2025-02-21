extends Node2D

@export_category("Node References")
@export var _menuManager : MenuManager
@export var _iconMenu : Menu
@export var _background : Control

class DataSaver extends SaveData.DataSaver:
	var test1
	var test2
	var test3
	var test4

func _ready() -> void:
	var testDataSaver = DataSaver.new()
	testDataSaver.get_property_list()
	for property : Dictionary in testDataSaver.get_property_list():
		if (property["name"] == "Built-in script" or property["name"] == "RefCounted" 
			or property["name"] == "script" or property["name"] == "obj"
			or property["name"] == "categoryName"):
			continue
		print(property["name"])

	SaveData.loadSettingsFromFile()


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

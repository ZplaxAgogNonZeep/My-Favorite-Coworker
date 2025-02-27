extends Control

class_name MenuManager

## This class is designed to manage a UI statemachine in a way that lets me just drop in
## new menus easier

@export_category("Node References")
@export var controller : Node2D # Usually the root of the scene, used to get information from non-singletons
@export_category("State Machine")
@export var _menuList : Array[Menu]
@export var _defaultMenuIndex : int
var _activeMenu : Menu

func _ready() -> void:
	for menu : Menu in _menuList:
		menu.visible = false
		menu.menuManager = self
		menu.ChangeMenu.connect(changeMenu) 


func _process(delta: float) -> void:
	if (_activeMenu):
		_activeMenu.menuBehavior()

func toggleMenu(isOpen: bool):
	if (isOpen):
		changeMenu(_defaultMenuIndex)
	else:
		changeMenu(-1)

#region State Machine
func changeMenu(menuIndex : int):
	if (menuIndex >= _menuList.size()):
		print("Menu System Error: Failed to find menu at index ", menuIndex)
		return
	
	if (menuIndex < 0 and _activeMenu):
		_activeMenu.closeMenu()
		_activeMenu = null
		return
	
	if (_activeMenu):
		await _activeMenu.closeMenu()
	
	_activeMenu = _menuList[menuIndex]
	
	await _activeMenu.openMenu()

func getActiveMenu() -> Menu:
	return _activeMenu


func isMenuOpen() -> bool:
	return _activeMenu != null
#endregion

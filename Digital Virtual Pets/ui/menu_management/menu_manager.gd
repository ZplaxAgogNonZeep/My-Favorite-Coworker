extends Control

class_name MenuManager

## This class is designed to manage a UI statemachine in a way that lets me just drop in
## new menus easier

@export var _menuList : Array[Menu]
var _activeMenu : Menu

func _ready() -> void:
	for menu : Menu in _menuList:
		menu.visible = false
		menu.ChangeMenu.connect(changeMenu)
	
	changeMenu(0)


func _process(delta: float) -> void:
	if (_activeMenu):
		_activeMenu.menuBehavior()


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


#endregion





extends Control

class_name MenuManager

## This class is designed to manage a UI statemachine in a way that lets me just drop in
## new menus easier

enum MenuMode {SINGLE_MENU, MULTI_MENU}

@export_category("Node References")
@export var controller : Node2D # Usually the root of the scene, used to get information from non-singletons
@export var _mouseDownSFX : SoundGroup
@export var _mouseUpSFX : SoundGroup
@export_category("State Machine")
@export var _menuMode := MenuMode.SINGLE_MENU
@export var _useOSWindows : bool = false
@export var _defaultMenuIndex : int
@export var _menuList : Array[Menu]

var _activeMenus : Array[Menu]

func _ready() -> void:
	GameEvents.OpenDirectMenu.connect(_openDirectMenu)
	var count = 0
	for menu : Menu in _menuList:
		menu.PlayMouseSFX.connect(_playMouseSFX)
		menu.visible = false
		menu.menuManager = self
		menu.index = count
		menu.ChangeMenu.connect(changeMenu)
		
		count += 1 


func _process(delta: float) -> void:
	for menu in _activeMenus:
		menu.menuBehavior()


func toggleMenu(isOpen: bool):
	if (isOpen):
		changeMenu(_defaultMenuIndex)
	else:
		changeMenu(-1)


func _updatePauseState():
	for menu in _activeMenus:
		if menu.pauseGame:
			Settings.pauseGame(true)
			return
	
	Settings.pauseGame(false)


#region State Machine
func changeMenu(menuIndex : int, direct := false):
	if (menuIndex >= _menuList.size()):
		print("Menu System Error: Failed to find menu at index ", menuIndex)
		return
	
	if (menuIndex < 0 and _activeMenus.size() > 0):
		_closeAllMenus()
		_activeMenus = []
		return
	
	match _menuMode:
		MenuMode.SINGLE_MENU:
			## Single Menu mode will close existing menus then open new ones
			if (_activeMenus.size() > 0):
				await _activeMenus[0].closeMenu()
			
			if (_activeMenus.size() == 0):
				_activeMenus.append(_menuList[menuIndex])
			else:
				_activeMenus[0] = _menuList[menuIndex]
			
			await _activeMenus[0].openMenu()
		MenuMode.MULTI_MENU:
			## Multi Menu mode will open menus, and close them if they're already open
			if (_activeMenus.has(_menuList[menuIndex])):
				await _menuList[menuIndex].closeMenu()
				_activeMenus.erase(_menuList[menuIndex])
			else:
				_activeMenus.append(_menuList[menuIndex])
				await _menuList[menuIndex].openMenu()
			
	_updatePauseState()

func _closeAllMenus():
	for menu in _activeMenus:
		menu.closeMenu()
	
	Settings.pauseGame(false)


func _openDirectMenu(index : int):
	changeMenu(index, true)

#endregion


#region Utility Functions

func getActiveMenu(index := 0) -> Menu:
	return _activeMenus[index]


func isMenuOpen() -> bool:
	return _activeMenus.size() > 0


func getMenuMode():
	return _menuMode


func _playMouseSFX(index : int):
	if (index == 0):
		SfxManager.playSoundEffect(_mouseDownSFX)
	else:
		SfxManager.playSoundEffect(_mouseUpSFX)

#endregion

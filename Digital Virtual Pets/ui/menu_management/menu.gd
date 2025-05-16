extends Control

class_name Menu

signal ChangeMenu(menuIndex: int)
signal PlayMouseSFX(index : int)

@export_category("Menu System Variables")
@export var pauseGame : bool = true
@export var _window : Window
@export_category("Animation Variables")
@export var animator : AnimationPlayer
@export var _animationLibrary : String

var menuManager : MenuManager
var index : int
var _openedDirectly := false

func _ready() -> void:
	animator.animation_finished.connect(_animationComplete)
	if _window:
		_window.visible = false


func menuBehavior():
	pass


func openMenu(direct := false):
	_openedDirectly = direct
	Settings.pauseGame(pauseGame)
	
	_loadSavedMenuSettings()
	
	animator.play(_animationLibrary + "/open")
	#animator is bugged so we need to wait a frame or it'll display the menu BEFORE playing the 
	# animation
	await get_tree().process_frame
	await get_tree().process_frame
	visible = true
	if (_window != null):
		_window.visible = true
	await animator.animation_finished
	print("doot")


func closeMenu():
	#TODO: Add a system for tracking what menus that are open want the game paused
	_saveMenuSettings()
	if (pauseGame):
		Settings.pauseGame(false)
	if !animator.has_animation(_animationLibrary +"/close"):
		animator.play("open", -1, -1, true)
	else:
		animator.play(_animationLibrary +"/close")
	
	await animator.animation_finished
	visible = false
	if (_window):
		_window.visible = false


func _onExit():
	if (_openedDirectly):
		ChangeMenu.emit(-1)
		return
	if (menuManager.getMenuMode() == MenuManager.MenuMode.SINGLE_MENU):
		ChangeMenu.emit(0)
	elif (menuManager.getMenuMode() == MenuManager.MenuMode.MULTI_MENU):
		ChangeMenu.emit(index)


func _loadSavedMenuSettings():
	pass


func _saveMenuSettings():
	print("Saving menu settings")
	Settings.saveSettings()

#region Node Signals
func _animationComplete(animation : StringName):
	pass

func _mouseDown():
	PlayMouseSFX.emit(0)


func _mouseUp():
	PlayMouseSFX.emit(1)

#endregion

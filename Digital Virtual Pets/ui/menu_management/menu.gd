extends Control

class_name Menu

signal ChangeMenu(menuIndex: int)

@export var animator : AnimationPlayer
@export var pauseGame : bool = true

var menuManager : MenuManager
var index : int

func _ready() -> void:
	animator.animation_finished.connect(_animationComplete)


func menuBehavior():
	pass


func openMenu():
	Settings.pauseGame(pauseGame)
	
	_loadSavedMenuSettings()
	
	animator.play("Open")
	#animator is bugged so we need to wait a frame or it'll display the menu BEFORE playing the 
	# animation
	await get_tree().process_frame
	visible = true
	await animator.animation_finished


func closeMenu():
	_saveMenuSettings()
	if !animator.has_animation("Close"):
		animator.play("Open", -1, -1, true)
	else:
		animator.play("Close")
	
	await animator.animation_finished
	visible = false


func _onExit():
	if (menuManager.getMenuMode() == MenuManager.MenuMode.SINGLE_MENU):
		ChangeMenu.emit(0)
	elif (menuManager.getMenuMode() == MenuManager.MenuMode.MULTI_MENU):
		ChangeMenu.emit(index)


func _loadSavedMenuSettings():
	pass


func _saveMenuSettings():
	Settings.saveSettings()

#region Node Signals
func _animationComplete(animation : StringName):
	pass


#endregion

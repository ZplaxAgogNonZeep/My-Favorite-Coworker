extends Control

class_name Menu

signal ChangeMenu(menuIndex: int)

@export var animator : AnimationPlayer
@export var pauseGame : bool = true

var menuManager : MenuManager

func _ready() -> void:
	animator.animation_finished.connect(_animationComplete)
	animator.animation_started.connect(_animationStarted)


func menuBehavior():
	pass


func openMenu():
	_loadSavedMenuSettings()
	
	animator.play("Open")
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
	ChangeMenu.emit(0)


func _loadSavedMenuSettings():
	pass


func _saveMenuSettings():
	Settings.saveSettings()

#region Node Signals
func _animationComplete(animation : StringName):
	pass


func _animationStarted(animation : StringName):
	pass
	#visible = true

#endregion

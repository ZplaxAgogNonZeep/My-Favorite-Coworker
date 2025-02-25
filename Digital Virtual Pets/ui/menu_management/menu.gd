extends Control

class_name Menu

signal ChangeMenu(menuIndex: int)

@export var animator : AnimationPlayer

func _ready() -> void:
	animator.animation_finished.connect(_animationComplete)


func menuBehavior():
	pass


func openMenu():
	_loadSavedMenuSettings()
	visible = true
	animator.play("Open")
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
#endregion

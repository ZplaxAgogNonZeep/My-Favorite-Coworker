extends Control

class_name Menu

signal ChangeMenu(menuIndex: int)

@export var animator : AnimationPlayer

func _ready() -> void:
	animator.animation_finished.connect(_animationComplete)

func menuBehavior():
	pass


func openMenu():
	_loadMenuSettingsFromFile()
	animator.play("Open")
	await animator.animation_finished


func closeMenu():
	_saveMenuSettingsToFile()
	if !animator.has_animation("Close"):
		animator.play("Open", -1, -1, true)
	else:
		animator.play("Close")
	
	await animator.animation_finished


func _loadMenuSettingsFromFile():
	pass


func _saveMenuSettingsToFile():
	pass

#region Node Signals
func _animationComplete(animation : StringName):
	pass
#endregion

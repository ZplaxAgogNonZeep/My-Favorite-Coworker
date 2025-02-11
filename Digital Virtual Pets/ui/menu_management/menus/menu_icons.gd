extends Menu

@export var _clickTimer : Timer


#region Menu Overrides
func menuBehavior():
	return
	if Input.is_action_just_pressed("Debug2"):
		if (_clickTimer.is_stopped()):
			_clickTimer.start()
		
		if (not _clickTimer.is_stopped()):
			if (visible):
				closeMenu()
			else:
				openMenu()


#endregion

#region Node Signals
func _onOptionsButton():
	ChangeMenu.emit(1)


func _onWindowButton():
	pass


func _onAudioButton():
	pass


func _onPetButton():
	pass
#enregion

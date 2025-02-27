extends Menu

@export var _clickTimer : Timer


#region Node Signals
func _onOptionsButton():
	ChangeMenu.emit(1)


func _onWindowButton():
	pass


func _onAudioButton():
	pass


func _onPetButton():
	ChangeMenu.emit(2)
#enregion

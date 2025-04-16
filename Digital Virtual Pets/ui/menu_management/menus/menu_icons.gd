extends Menu

@export_category("Menu Selection Icon Variables")
@export var _petMenuButton : Button

func _loadSavedMenuSettings():
	_petMenuButton.disabled = menuManager.controller.device == null

#region Node Signals
func _onOptionsButton():
	ChangeMenu.emit(1)


func _onWindowButton():
	pass


func _onAudioButton():
	pass


func _onPetButton():
	ChangeMenu.emit(2)


func _onCloseButton():
	ChangeMenu.emit(-1)
#endregion

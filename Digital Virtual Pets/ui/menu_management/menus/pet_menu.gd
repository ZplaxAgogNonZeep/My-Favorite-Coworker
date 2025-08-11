extends Menu

@export_category("Pet Menu")
@export var _slotContainer : VBoxContainer
@export var _slotScene : PackedScene
@export var _subMenus : Array[Control]

var _subMenuIndex : int
var _currentSelectedSlot : int
var _petManager : PetManager

func _notification(what: int) -> void:
	if (what == NOTIFICATION_WM_CLOSE_REQUEST):
		SaveData.saveGameToFile()

func openMenu(direct := false):
	super(direct)
	if (PetManager.instance):
		PetManager.instance.gatherDataFromActivePet()
	_fillPetSlots()
	_subMenus[0].visible = true
	_subMenus[1].visible = false

func closeMenu():
	super()
	
	var count = _slotContainer.get_child_count() - 1
	while (count >= 0):
		_slotContainer.get_child(count).queue_free()
		count -= 1

func _loadSavedMenuSettings():
	if (PetManager.instance):
		_petManager = PetManager.instance
		_currentSelectedSlot = _petManager.getSlotIndex()


func _switchSubMenu(index := -1):
	if (_subMenus.size() <= 1 or _subMenuIndex == index):
		return
	
	_subMenus[_subMenuIndex].visible = false
	
	if (_subMenus[_subMenuIndex].has_method("closeSubMenu")):
		_subMenus[_subMenuIndex].closeSubMenu()
	
	if (index > -1):
		_subMenuIndex = index
	else:
		_subMenuIndex += 1
	
	if (_subMenuIndex >= _subMenus.size()):
		_subMenuIndex = 0
	elif _subMenuIndex < 0:
		_subMenuIndex = _subMenus.size() - 1
	
	animator.play(_animationLibrary + "/close")
	await animator.animation_finished
	animator.play(_animationLibrary + "/open")
	_subMenus[_subMenuIndex].visible = true
	if (_subMenus[_subMenuIndex].has_method("openSubMenu")):
		_subMenus[_subMenuIndex].openSubMenu()
	
	

#region Helper Functions

func _fillPetSlots():
	var petSlots = _petManager.getPetSlots()
	if (petSlots.size() == 0):
		var newSlot = _slotScene.instantiate()
		newSlot.loadPetData(null, 0)
		newSlot.NewPetSelected.connect(_createNewPet)
		newSlot.button_down.connect(_mouseDown)
		newSlot.button_up.connect(_mouseUp)
		_slotContainer.call_deferred("add_child", newSlot)
		return
	var count = 0
	for petData in petSlots:
		var newSlot = _slotScene.instantiate()
		if (count == _currentSelectedSlot):
			newSlot.button_pressed = true
		newSlot.loadPetData(petData, count)
		newSlot.PetSlotSelected.connect(_selectPet)
		newSlot.DeleteSaveSlot.connect(_deleteSlot)
		newSlot.button_down.connect(_mouseDown)
		newSlot.button_up.connect(_mouseUp)
		_slotContainer.call_deferred("add_child", newSlot)
		count += 1
	
	if (count < PetManager.MAX_PET_SLOTS):
		var newSlot = _slotScene.instantiate()
		newSlot.loadPetData(null, count)
		newSlot.NewPetSelected.connect(_createNewPet)
		newSlot.button_down.connect(_mouseDown)
		newSlot.button_up.connect(_mouseUp)
		_slotContainer.call_deferred("add_child", newSlot)


func _setSelectedHighlight(turnOnSelected := true):
	var count = 0
	for slot in _slotContainer.get_children():
		if (slot.index == _currentSelectedSlot):
			if (turnOnSelected):
				slot.set_pressed_no_signal(true)
		else:
			slot.set_pressed_no_signal(false)
		count += 1


func _updateIndexes(skipIndex : int):
	var count = 0
	var skipCount = 0
	for slot in _slotContainer.get_children():
		if (count == skipIndex):
			count += 1
			slot.index = -1
			continue
		slot.index = skipCount
		count += 1
		skipCount += 1

#endregion

#region Signal Functions

func _selectPet(index : int):
	_currentSelectedSlot = index
	_setSelectedHighlight(false)


func _createNewPet():
	_switchSubMenu()
	#GameEvents.ChangePet.emit(_petManager.getPetSlots().size())
	#if (_openedDirectly):
		#ChangeMenu.emit(-1)
		#return
	#if (menuManager.getMenuMode() == MenuManager.MenuMode.MULTI_MENU):
		#ChangeMenu.emit(index)
	#else:
		#ChangeMenu.emit(0)


func menuisdonepleaseremove():
	if (_openedDirectly):
		ChangeMenu.emit(-1)
		return
	if (menuManager.getMenuMode() == MenuManager.MenuMode.MULTI_MENU):
		ChangeMenu.emit(index)
	else:
		ChangeMenu.emit(0)


func _loadSelectedPet():
	GameEvents.ChangePet.emit(_currentSelectedSlot)
	if (_openedDirectly):
		ChangeMenu.emit(-1)
		return
	if (menuManager.getMenuMode() == MenuManager.MenuMode.MULTI_MENU):
		ChangeMenu.emit(index)
	else:
		ChangeMenu.emit(0)


func _deleteSlot(index : int):
	if (_petManager.getPetSlots().size() == 1):
		return
		# Probably play some noise or throw out a warning
	_petManager.deletePetSlot(index)
	_updateIndexes(index)
	if (_currentSelectedSlot >= index and _currentSelectedSlot != 0):
		_currentSelectedSlot -= 1
		print(_currentSelectedSlot)
	else:
		print(_currentSelectedSlot)
	_setSelectedHighlight()
	_slotContainer.get_child(index).queue_free()
	
	

#endregion

extends Menu

@export_category("Pet Menu")
@export var _slotContainer : VBoxContainer
@export var _slotScene : PackedScene

var _currentSelectedSlot : int
var _petManager : PetManager

func openMenu():
	super()
	_fillPetSlots()

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


#region Helper Functions

func _fillPetSlots():
	var petSlots = _petManager.getPetSlots()
	
	var count = 0
	for petData in petSlots:
		var newSlot = _slotScene.instantiate()
		if (count == _currentSelectedSlot):
			newSlot.button_pressed = true
		newSlot.loadPetData(petData, count)
		newSlot.PetSlotSelected.connect(_selectPet)
		newSlot.DeleteSaveSlot.connect(_deleteSlot)
		
		_slotContainer.call_deferred("add_child", newSlot)
		count += 1
	
	if (count < PetManager.MAX_PET_SLOTS):
		var newSlot = _slotScene.instantiate()
		newSlot.loadPetData(null, count)
		newSlot.NewPetSelected.connect(_createNewPet)
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
	GameEvents.ChangePet.emit(_petManager.getPetSlots().size())
	if (menuManager.getMenuMode() == MenuManager.MenuMode.MULTI_MENU):
		ChangeMenu.emit(index)
	else:
		ChangeMenu.emit(0)


func _loadSelectedPet():
	print(_currentSelectedSlot)
	GameEvents.ChangePet.emit(_currentSelectedSlot)
	if (menuManager.getMenuMode() == MenuManager.MenuMode.MULTI_MENU):
		ChangeMenu.emit(index)
	else:
		ChangeMenu.emit(0)


func _deleteSlot(index : int):
	print("Deleting save slot ", index)
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

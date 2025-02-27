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
	
	if (count < PetManager.MAX_PET_SLOTS - 1):
		var newSlot = _slotScene.instantiate()
		newSlot.loadPetData(null, count)
		newSlot.NewPetSelected.connect(_createNewPet)
		_slotContainer.call_deferred("add_child", newSlot)


func _setSelectedHighlight(turnOnSelected := true):
	var count = 0
	for slot in _slotContainer.get_children():
		if (count == _currentSelectedSlot):
			if (turnOnSelected):
				slot.button_pressed = true
		else:
			slot.button_pressed = false
		count += 1

#endregion

#region Signal Functions

func _selectPet(index : int):
	_currentSelectedSlot = index
	_setSelectedHighlight(false)


func _createNewPet():
	pass


func _loadSelectedPet():
	GameEvents.ChangePet.emit(_currentSelectedSlot)
	ChangeMenu.emit(0)


func _deleteSlot(index : int):
	pass

#endregion

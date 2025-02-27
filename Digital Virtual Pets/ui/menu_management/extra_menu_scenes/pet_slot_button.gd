extends Button

signal PetSlotSelected
signal NewPetSelected
signal DeleteSaveSlot

var index : int

func loadPetData(petData, slotIndex : int):
	if (petData == null):
		$NewPetSlot.visible = true
	else:
		index = slotIndex
		$Name.text = petData["petResource"].name
		$Icon.texture = petData["petResource"].getSpriteIcon()


func newPetPressed():
	NewPetSelected.emit()


func petSlotToggled(toggle : bool):
	if (toggle):
		PetSlotSelected.emit(index)
	else:
		print(name, " turned off")


func deleteSaveSlot():
	DeleteSaveSlot.emit(index)

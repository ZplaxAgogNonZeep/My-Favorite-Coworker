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
		var tex = CanvasTexture.new()
		var tex2 = ImageTexture.new()
		tex2.set_image(petData["petResource"].getSpriteIcon().get_image())
		tex.diffuse_texture = tex2
		tex.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		
		$Icon.texture = tex

		var array = Lifespan.convertLifespanToAge(petData.age)
		$Age.text = ("Age: " + str(int(array[0])) + "d " + 
								str(int(array[1])) + "h " + 
								str(int(array[2])) + "m")


func newPetPressed():
	NewPetSelected.emit()


func petSlotToggled(toggle : bool, isByUser := false):
	if (toggle):
		PetSlotSelected.emit(index)
	else:
		set_pressed_no_signal(true)


func deleteSaveSlot():
	DeleteSaveSlot.emit(index)

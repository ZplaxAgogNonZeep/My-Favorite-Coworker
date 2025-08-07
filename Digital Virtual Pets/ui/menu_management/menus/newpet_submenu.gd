extends Control

signal MenuDonePleaseGo

@export var _textEntry : TextEdit
@export var _eggContainer : HBoxContainer
@export var _createPetButton : Button
@export var _eggButton : PackedScene

var _selectedEgg : PetTypeData

func openSubMenu():
	_textEntry.placeholder_text = "Select a new egg"
	_textEntry.text = ""
	_textEntry.editable = false
	_selectedEgg = null
	_createPetButton.disabled = true
	_fillEggSelection()


func _fillEggSelection():
	var eggs = PetManager.instance.getPetProgressInformation()[0]
	
	for egg in eggs:
		var button = _eggButton.instantiate()
		# Set Icon
		var tex = CanvasTexture.new()
		var tex2 = ImageTexture.new()
		var image : Image = egg.getSpriteIcon().get_image()
		tex2.set_image(image)
		
		tex.diffuse_texture = tex2
		tex.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		button.icon = tex
		button.petData = egg
		
		button.EggSelected.connect(_eggButtonSelected)
		
		_eggContainer.add_child(button)


func _eggButtonSelected(petData : PetTypeData):
	_textEntry.editable = true
	_textEntry.placeholder_text = petData.name
	_selectedEgg = petData
	_createPetButton.disabled = false


func _createPetSelected():
	PetManager.instance.createNewPet(_selectedEgg, _textEntry.text)
	MenuDonePleaseGo.emit()
	

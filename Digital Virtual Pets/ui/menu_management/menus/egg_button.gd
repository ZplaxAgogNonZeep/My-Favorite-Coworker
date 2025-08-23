extends Button

signal EggSelected(petData : PetTypeData)

var petData : PetTypeData

func _eggSelected():
	EggSelected.emit(petData)

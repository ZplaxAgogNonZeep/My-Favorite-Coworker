extends Button

@export var _markers : Array[Marker2D]

var petData : PetTypeData

func getTrueSize() -> Vector2:
	return size + Vector2(0,$Name.size)

func setName(petName : String) -> void:
	$Name.text = petName

func getLineMarker(isRight : bool):
	if isRight:
		return _markers[1].position + position
	else:
		return _markers[0].position + position

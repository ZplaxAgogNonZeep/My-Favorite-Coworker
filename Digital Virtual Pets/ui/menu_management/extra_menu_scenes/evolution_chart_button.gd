extends Button

signal TreeNodePressed(petData : PetTypeData)

@export var _markers : Array[Marker2D]
var petData : PetTypeData

func _onToggled(toggled_on : bool):
	if toggled_on:
		TreeNodePressed.emit(petData)
	elif pressed:
		set_pressed_no_signal(true)


func setName(petName : String) -> void:
	$Name.text = petName


func getLineMarker(isRight : bool):
	if isRight:
		return _markers[1].position + position
	else:
		return _markers[0].position + position

func setSilhouette(texture):
	$SilhouetteIcon.icon = texture

func toggleSilhouette(on : bool):
	$SilhouetteIcon.visible = on

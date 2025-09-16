extends Button

signal TreeNodePressed(petData : PetTypeData)

@export var _markers : Array[Marker2D]
var petData : PetTypeData
@export var _hoverTimer : Timer
var _hovered : bool = false

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

func getParallelMarker(isAbove : bool):
	if isAbove:
		return _markers[2].position + position
	else:
		return _markers[3].position + position

func setSilhouette(texture):
	$SilhouetteIcon.icon = texture


func toggleSilhouette(on : bool):
	$SilhouetteIcon.visible = on


func _openTooltip():
	if (!_hovered):
		_hovered = true
		_hoverTimer.start(.1)


func _closeTooltip():
	if (_hovered):
		_hovered = false
		if (!_hoverTimer.is_stopped()):
			_hoverTimer.stop()
		else:
			GameEvents.DismissToolTip.emit()


func _hoverTimerComplete():
	GameEvents.CallToolTip.emit(DisplayServer.mouse_get_position() + Vector2i(5, 5), 
								petData.getFormattedEvolutionConditions())

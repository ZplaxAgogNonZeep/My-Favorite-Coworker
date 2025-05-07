extends AnimatedSprite2D

signal DeviceButtonPressed(button : Enums.DeviceButton)

@export var _assignedButton : Enums.DeviceButton

var _hovered = false

func _ready() -> void:
	animation_finished.connect(_playSoundEffect)

func _mouseEntered():
	_hovered = true

func _mouseExited():
	_hovered = false
	

func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and _hovered):
		if (event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()):
			set_frame_and_progress(0, 0)
			play()
			DeviceButtonPressed.emit(_assignedButton)


func _playSoundEffect():
	pass
	#SfxManager.playSoundEffect(get_parent().get_parent()._buttonUpSound)

extends AnimatedSprite2D

signal DeviceButtonPressed(buttonIndex : int)

var _hovered = false

func _mouseEntered():
	_hovered = true

func _mouseExited():
	_hovered = false
	

func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and _hovered):
		if (event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()):
			set_frame_and_progress(0, 0)
			play()

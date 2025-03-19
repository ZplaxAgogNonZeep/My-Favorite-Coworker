extends Sprite2D

signal ButtonPressed(button : Enums.DeviceButton)

func _deviceButtonPressed(button : Enums.DeviceButton):
	ButtonPressed.emit(button)

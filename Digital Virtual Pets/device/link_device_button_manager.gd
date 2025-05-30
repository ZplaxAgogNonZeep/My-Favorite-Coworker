extends Sprite2D

signal ButtonPressed(button : Enums.DeviceButton)

@export var _buttonDownSound : SoundGroup
@export var _buttonUpSound : SoundGroup

func _deviceButtonPressed(button : Enums.DeviceButton):
	SfxManager.playSoundEffect(_buttonDownSound)
	ButtonPressed.emit(button)

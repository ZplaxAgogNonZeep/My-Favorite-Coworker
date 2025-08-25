extends Sprite2D

signal ButtonPressed(button : Enums.DeviceButton)

@export var _buttonDownSound : SoundGroup
@export var _buttonUpSound : SoundGroup

func _deviceButtonPressed(button : Enums.DeviceButton):
	changePalette()
	SfxManager.playSoundEffect(_buttonDownSound)
	if (!get_tree().paused):
		ButtonPressed.emit(button)
		


func changePalette():
	print(material.get("shader_parameter/palette"))

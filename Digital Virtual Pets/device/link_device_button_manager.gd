extends Sprite2D

signal ButtonPressed(button : Enums.DeviceButton)
@export_category("Skin Data")
@export var _skins : Array[Texture2D]
@export var _palettes : Array[Texture2D]
@export_category("Sound Groups")
@export var _buttonDownSound : SoundGroup
@export var _buttonUpSound : SoundGroup

func _ready() -> void:
	GameEvents.DeviceUpdateSkin.connect(_updateSkin)
	_updateSkin()

func _deviceButtonPressed(button : Enums.DeviceButton):
	SfxManager.playSoundEffect(_buttonDownSound)
	if (!get_tree().paused):
		ButtonPressed.emit(button)


func _updateSkin():
	texture = _skins[Settings.deviceSkin.x]
	material.palette = _palettes[Settings.deviceSkin.x]
	material.row = Settings.deviceSkin.y

extends AnimatedSprite2D


func _ready() -> void:
	GameEvents.DeviceUpdateSkin.connect(_updateSkin)
	_updateSkin()


func _updateSkin():
	#texture = _skins[Settings.deviceSkin.x]
	#material.palette = _palettes[Settings.deviceSkin.x]
	material.row = Settings.deviceSkin.y

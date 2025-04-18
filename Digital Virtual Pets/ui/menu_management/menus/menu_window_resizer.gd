extends Window

@export var _canvas : Control
@export var _windowType : Settings.SubWindowPositionType

func _visibilityChanged():
	if (visible):
		size = _canvas.size
	
	position = Settings.findValidWindowPosition(_windowType, size)

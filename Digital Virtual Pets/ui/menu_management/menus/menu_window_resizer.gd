extends Window

@export var _canvas : Control

func _visibilityChanged():
	if (visible):
		size = _canvas.size

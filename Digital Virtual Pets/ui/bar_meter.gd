extends Node2D

enum Axis {HORIZONTAL, VERTICAL}

@export_category("Node References")
@export var _stretchBar : Sprite2D
@export var _endMarker : Marker2D
@export_category("Settings")
@export var _orientation : Axis


func setValue(value : float, max: float):
	var maxDistance
	
	if (_orientation == Axis.HORIZONTAL):
		maxDistance = _endMarker.position.x
	else:
		maxDistance = _endMarker.position.y
	
	if (_orientation == Axis.HORIZONTAL):
		_stretchBar.scale.x = lerpf(0, maxDistance, value / max)
	else:
		_stretchBar.scale.y = lerpf(0, maxDistance, value / max)

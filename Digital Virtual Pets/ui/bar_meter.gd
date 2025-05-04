extends Node2D

class_name Meter

enum Axis {HORIZONTAL, VERTICAL}

@export_category("Node References")
@export var _stretchBar : Sprite2D
@export var _startMarker : Marker2D
@export var _endMarker : Marker2D
@export_category("Settings")
@export var _orientation : Axis

## Sets the meter to be a standard left to right progress bar, using the given [param value] as the progress
## and the [param max] as the compared maximum
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


## Sets the meter to be a sectional bar, allowing it to show a portion of the total bar instead of a standard
## view. It uses the given [param startSection] and the given [param endSection] to determine the visible
## section compared to the given [param maxValue].
func setSectionValue(startSection: float, endSection : float, maxValue: float):
	var sectionSize = endSection - startSection
	var maxDistance
	
	if (_orientation == Axis.HORIZONTAL):
		maxDistance = _endMarker.position.x
		_stretchBar.scale.x = sectionSize
	else:
		maxDistance = _endMarker.position.y
		_stretchBar.scale.y = sectionSize
	
	if (_orientation == Axis.HORIZONTAL):
		_stretchBar.position.x = lerpf(0, maxDistance, startSection / maxValue)
	else:
		_stretchBar.position.y = lerpf(0, maxDistance, startSection / maxValue)

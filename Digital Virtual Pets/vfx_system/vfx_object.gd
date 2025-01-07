extends Node2D

class_name VFXObject

signal VFXObjectComplete(vfx : VFXObject)

@export_category("General VFX Variables")
@export var _lifetime : float

@export_category("Object References")
@export var lifeTimer : Timer

var attachedObject : Node2D = null

var _active := false

func vfxReady() -> void:
	print("vfxReady")
	if lifeTimer != null:
		_startLifespanTimer()
	_active = true


func _startLifespanTimer():
	lifeTimer.timeout.connect(vfxComplete)
	lifeTimer.start(_lifetime)


func vfxComplete() -> void:
	visible = false
	VFXObjectComplete.emit(self)

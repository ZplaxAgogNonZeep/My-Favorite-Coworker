extends Node2D

class_name VFXManager

enum VisualEffects {DUSTCLOUD}

@export var _effectArray : Array[PackedScene]
@export var _isForGameArea : bool

var _vfxPool : Array[VFXObject]

func _ready() -> void:
	if _isForGameArea:
		GameEvents.PlayGameVFX.connect(_playVFX)
	else:
		GameEvents.PlayDeviceVFX.connect(_playVFX)


func _playVFX(effect : VFXManager.VisualEffects, position : Vector2, isFacingRight : bool,
																		lifespan : float) -> VFXObject:
	var effectToSpawn : VFXObject = _effectArray[effect].instantiate()
	print("Play VFX Called")
	effectToSpawn.position = position
	effectToSpawn._lifetime = lifespan
	if effectToSpawn is VFXSprite:
		effectToSpawn.toggleDirection(isFacingRight)
	
	call_deferred("add_child", effectToSpawn)
	effectToSpawn.VFXObjectComplete.connect(_removeVFXObject)
	print("Calling vfxready")
	effectToSpawn.vfxReady()
	
	
	return effectToSpawn


func _playAttachedVFX(effect : VFXManager.VisualEffects, localPosition : Vector2, 
				lifespan : float, isFacingRight : bool, attachedObject : Node2D) -> void:
	pass

func _removeVFXObject(vfx : VFXObject) -> void:
	_vfxPool.erase(vfx)
	vfx.queue_free()

extends Node2D

class_name EvolvingPet

@export_category("Object References")
@export var _previousEvo : Sprite2D
@export var _nextEvo : Sprite2D

var _speedRate : float

signal SequenceComplete


func startSequence(evolvePosn : Vector2, oldTexture : Texture2D, oldOffset : float, 
					newTexture : Texture2D, newOffset : float, rate : float) -> void:
	_previousEvo.texture = oldTexture
	_previousEvo.offset.y = oldOffset
	_nextEvo.texture = newTexture
	_nextEvo.offset.y = newOffset
	_speedRate = rate
	position = evolvePosn
	$AnimationPlayer.speed_scale = 1
	
	visible = true
	$AnimationPlayer.play("evolve_sequence_anim")


func _incrementSequence(anim_name: StringName) -> void:
	if ($AnimationPlayer.speed_scale < 4):
		$AnimationPlayer.speed_scale *= 1.1
	else:
		$AnimationPlayer.stop(true)
		visible = false
		SequenceComplete.emit()

extends Node2D

class_name ThoughtBubble

enum PetMood {NONE, TRAUMA, HAPPY, SAD, MAD}

@export var pet : Pet
@export var _bubbleSprite : Sprite2D
@export var _moodIcon : AnimatedSprite2D
@export var _petSpriteOffset : int
@export var _moodDisplayTime : float
@export var _timer : Timer
var _dir : bool = false
var _currentMood : PetMood = PetMood.NONE

func _ready() -> void:
	visible = false

func setDirection(dir : bool):
	if (dir == _dir):
		return
	
	_dir = dir
	_bubbleSprite.flip_h = _dir
	
	if (_dir):
		position.x = pet.position.x + (_petSpriteOffset + 
									(_bubbleSprite.texture.get_size().x * .5) + 
									(2 * pet.petResource.stage))
	else:
		position.x = pet.position.x - (_petSpriteOffset + 
									(_bubbleSprite.texture.get_size().x * .5) + 
									(2 * pet.petResource.stage))


func setMood(mood : PetMood):
	if (mood == PetMood.NONE):
		return
	
	visible = true
	
	match mood:
		PetMood.TRAUMA:
			_moodIcon.play("Trauma")
	
	_timer.start(_moodDisplayTime)
	await _timer.timeout
	visible = false
	_currentMood = PetMood.NONE


func isActive() -> bool:
	return _currentMood != PetMood.NONE


func getMood() -> PetMood:
	return _currentMood

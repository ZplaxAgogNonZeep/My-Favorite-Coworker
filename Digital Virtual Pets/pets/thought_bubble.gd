extends Node2D

class_name ThoughtBubble

enum PetMood {TRAUMA, HAPPY}

@export var pet : Pet
@export var _bubbleSprite : Sprite2D
@export var _moodIcon : AnimatedSprite2D
@export var _petSpriteOffset : int
@export var _moodDisplayTime : float
@export var _timer : Timer
var _dir : bool = false

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
	visible = true
	
	match mood:
		PetMood.TRAUMA:
			_moodIcon.play("Trauma")
	
	_timer.start(_moodDisplayTime)
	await _timer.timeout
	visible = false
	
	
	

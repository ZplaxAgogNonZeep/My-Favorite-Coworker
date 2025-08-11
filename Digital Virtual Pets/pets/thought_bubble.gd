extends Node2D

class_name ThoughtBubble

@export var pet : Pet
@export var _bubbleSprite : Sprite2D
@export var _moodIcon : AnimatedSprite2D
@export var _spriteOffset : int
@export var _petSpriteOffset : int
var _dir : bool = false

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

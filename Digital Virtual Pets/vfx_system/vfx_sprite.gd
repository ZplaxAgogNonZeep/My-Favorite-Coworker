extends VFXObject

class_name VFXSprite

enum BehaviorTypes {CUSTOM, STRAIGHT_HORI, STRAIGHT_VERT, FOLLOW}

@export_category("Sprite Variables")
@export var sprite : AnimatedSprite2D
@export var _behavior : BehaviorTypes
@export var _speed : float
@export_range(0, 1) var _blinkRatio : float

var givenPosition : Vector2

func _process(delta: float) -> void:
	if not _active:
		return
	
	match _behavior:
		BehaviorTypes.STRAIGHT_HORI:
			# Direction will auto align to whatever direction it's already facing
			if sprite.flip_h:
				# Sprite Facing Right
				position.x += _speed * delta
			else:
				# Sprite Facing Left
				position.x -= _speed * delta
		BehaviorTypes.STRAIGHT_VERT:
			# Speed will determine if it goes up or down
			position.y -= _speed * delta
		BehaviorTypes.CUSTOM:
			_customBehavior()
		BehaviorTypes.FOLLOW:
			if (attachedObject == null):
				return
			
			position = attachedObject.position + givenPosition
			

func _startLifespanTimer():
	sprite.play("Active")
	lifeTimer.timeout.connect(_startBlinking)
	#lifeTimer.autostart = true
	lifeTimer.start(_lifetime * (1 - _blinkRatio))


func _startBlinking():
	if not lifeTimer.timeout.is_connected(vfxComplete):
		lifeTimer.timeout.connect(vfxComplete)
	sprite.play("Blinking")
	lifeTimer.start(_lifetime * _blinkRatio)


func toggleDirection(isFacingRight : bool):
	sprite.flip_h = isFacingRight


func _customBehavior():
	pass

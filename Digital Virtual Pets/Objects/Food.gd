extends RigidBody2D

var implements = [Interface.Food]

signal FinishedEating

@export var collision : CollisionShape2D
@export var _sprite : AnimatedSprite2D
@export var _rotTimer : Timer
@export var _rotTimeLimit : float

var feedAmount := 100
var fallSpeed := 1
var stopFallingAt : int
var readyToEat := false
var hasEmittedVFX := false
var rotten := false

func _ready() -> void:
	GameEvents.ShakeDeviceOnce.connect(deviceMoving)
	GameEvents.StartShakeDevice.connect(deviceMoving)
	GameEvents.HopDeviceOnce.connect(deviceMoving)
	GameEvents.StartHopDevice.connect(deviceMoving)
	GameEvents.FinishedShakeDevice.connect(deviceNotMoving)
	GameEvents.FinishedHopDevice.connect(deviceNotMoving)
	
	# I don't know why I have to do this but when spawning in a kinematic body, it will always try to
	# adjust itself to be 1x scale based on the parent
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	$CollisionShape2D.scale = Vector2.ONE * 2
	$Sprite2D.scale = Vector2.ONE * 2
	
	$CollisionShape2D.position.y *= 2
	$Sprite2D.position.y *= 2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (position.y < stopFallingAt and not freeze):
		var coll = move_and_collide(Vector2(0, fallSpeed))
		if (coll != null and not hasEmittedVFX):
			hasEmittedVFX = true
			_onBodyCollision(coll.get_collider())
			_rotTimer.start(_rotTimeLimit * Settings.getTimerMod())
	elif (position.y >= stopFallingAt):
		if not readyToEat:
			collision.visible = true
			freeze = true
			readyToEat = true
			GameEvents.FoodPlaced.emit(self)
			if (!rotten and _rotTimer.is_stopped()):
				_rotTimer.start(_rotTimeLimit * Settings.getTimerMod())


func deviceMoving():
	if (not readyToEat):
		freeze = true


func deviceNotMoving():
	if (not readyToEat):
		freeze = false

func startEating():
	_sprite.play("Eating")
	_rotTimer.stop()


func _onBodyCollision(body):
	if Interface.hasInterface(body, Interface.Food):
		if position.y < body.position.y:
			GameEvents.PlayGameVFX.emit(VFXManager.VisualEffects.DUSTCLOUD, position + Vector2(13, 0), true, 2)
			GameEvents.PlayGameVFX.emit(VFXManager.VisualEffects.DUSTCLOUD, position - Vector2(13, 0), false, 2)


func completeAnimation():
	if (_sprite.animation == "Eating"):
		FinishedEating.emit()


func _rotTimerTimeout():
	print("Timeout", rotten, " ", _sprite.animation)
	if (!rotten and _sprite.animation == "Idle"):
		rotten = true
		_sprite.play("Rotten")

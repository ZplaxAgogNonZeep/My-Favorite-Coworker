extends RigidBody2D

var implements = [Interface.Food]

var feedAmount := 50
var fallSpeed := 1
var stopFallingAt : int
var readyToEat := false
var hasEmittedVFX := false

func _ready() -> void:
	GameEvents.ShakeDeviceOnce.connect(deviceMoving)
	GameEvents.StartShakeDevice.connect(deviceMoving)
	GameEvents.HopDeviceOnce.connect(deviceMoving)
	GameEvents.StartHopDevice.connect(deviceMoving)
	GameEvents.FinishedShakeDevice.connect(deviceNotMoving)
	GameEvents.FinishedHopDevice.connect(deviceNotMoving)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (position.y < stopFallingAt and not freeze):
		var coll = move_and_collide(Vector2(0, fallSpeed))
		if (coll != null and not hasEmittedVFX):
			hasEmittedVFX = true
			_onBodyCollision(coll.get_collider())
	elif (position.y >= stopFallingAt):
		if not readyToEat:
			freeze = true
			readyToEat = true
			GameEvents.FoodPlaced.emit(self)
			

func deviceMoving():
	if (not readyToEat):
		freeze = true


func deviceNotMoving():
	if (not readyToEat):
		freeze = false


func _onBodyCollision(body):
	if Interface.hasInterface(body, Interface.Food):
		if position.y < body.position.y:
			GameEvents.PlayGameVFX.emit(VFXManager.VisualEffects.DUSTCLOUD, position, false, 2)

extends Node2D

@export
var activePet : Node2D

var chatSpeed := .1


# Called when the node enters the scene tree for the first time.
func _ready():
	GameEvents.ShakeDeviceOnce.connect(shake)
	GameEvents.HopDeviceOnce.connect(hop)
	GameEvents.StartShakeDevice.connect(startShake)
	GameEvents.EndShakeDevice.connect(endShake)
	GameEvents.StartHopDevice.connect(startHop)
	GameEvents.endHopDevice.connect(endShake)
	

# Events ===========================================================================================

func hop():
	pass

func shake():
	pass

func startShake():
	pass

func startHop():
	pass

func endShake():
	pass

func endHop():
	pass

# Tween Controls ===================================================================================

func shakeLeft():
	pass

func shakeRight():
	pass

func hopUp():
	pass

func hopDown():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

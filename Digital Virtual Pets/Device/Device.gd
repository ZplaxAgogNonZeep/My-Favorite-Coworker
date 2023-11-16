extends Node2D

enum DeviceAction {HOP, SHAKE}

@onready var originalPosn := position

@export var activePet : Node2D
@export_category("Movement Variables")
@export_range(0, 360) var shakeDegreeMax = PI
@export var hopHeight : Vector2
@export var shakeDuration : float
@export var hopDuration : float
@export_category("Modifiers")
@export var chatSpeed : float

var activeTween : Tween
var isContinuousShake := false
var isContinuousHop := false
var actionQueue : Array[DeviceAction] = []


func _ready():
	GameEvents.ShakeDeviceOnce.connect(shake)
	GameEvents.HopDeviceOnce.connect(hop)
	GameEvents.StartShakeDevice.connect(startShake)
	GameEvents.EndShakeDevice.connect(endShake)
	GameEvents.StartHopDevice.connect(startHop)
	GameEvents.endHopDevice.connect(endShake)
	

# Events ===========================================================================================

func hop():
	if not activeTween:
		isContinuousHop = false
		hopUp()
	else:
		actionQueue += [DeviceAction.HOP]

func shake():
	if not activeTween:
		isContinuousShake = false
		shakeLeft()
	else:
		actionQueue += [DeviceAction.SHAKE]

func startShake():
	if not activeTween:
		isContinuousShake = true
		shakeLeft()

func startHop():
	if not activeTween:
		isContinuousHop = true
		hopUp()

func endShake():
	pass

func endHop():
	pass

# Tween Controls ===================================================================================

func checkQueue():
	if actionQueue.size() > 0:
		if actionQueue[actionQueue.size() - 1] == DeviceAction.SHAKE:
			actionQueue.remove_at(actionQueue.size() - 1)
			shakeLeft()
		elif actionQueue[actionQueue.size() - 1] == DeviceAction.HOP:
			actionQueue.remove_at(actionQueue.size() - 1)
			hopUp()
		return false
	else:
		return true

func shakeLeft(isStart : bool = true):
	if isStart:
		activeTween = get_tree().create_tween()
		activeTween.set_ease(Tween.EASE_IN_OUT)
		activeTween.tween_property(self, 
									"rotation_degrees", 
									shakeDegreeMax * -1, 
									shakeDuration * .5).connect("finished", shakeRight)
	else:
		activeTween = get_tree().create_tween()
		activeTween.set_ease(Tween.EASE_IN_OUT)
		activeTween.tween_property(self, 
									"rotation_degrees", 
									shakeDegreeMax * -1, 
									shakeDuration).connect("finished", shakeRight)

func shakeRight():
	activeTween = get_tree().create_tween()
	activeTween.tween_property(self, 
								"rotation_degrees", 
								shakeDegreeMax, 
								shakeDuration).connect("finished", completeOneShake)

func completeOneShake():
	if isContinuousShake:
		shakeLeft(false)
	else:
		activeTween = get_tree().create_tween()
		activeTween.set_ease(Tween.EASE_IN_OUT)
		activeTween.tween_property(self, 
									"rotation_degrees", 
									0, 
									shakeDuration * .5).connect("finished", finishedShaking)

func finishedShaking():
	if (checkQueue()):
		activeTween = null
		GameEvents.FinishedShakeDevice.emit()

func hopUp():
	activeTween = get_tree().create_tween()
	activeTween.set_ease(Tween.EASE_IN_OUT)
	activeTween.tween_property(self, "position", position + hopHeight, 
								hopDuration * .5).connect("finished", hopDown)

func hopDown():
	activeTween = get_tree().create_tween()
	activeTween.set_ease(Tween.EASE_IN_OUT)
	activeTween.tween_property(self, "position", originalPosn, 
								hopDuration * .5).connect("finished", completedOneHop)

func completedOneHop():
	if isContinuousHop:
		hopUp()
	else:
		if (checkQueue()):
			finishedHopping()

func finishedHopping():
	activeTween = null
	GameEvents.FinishedHopDevice.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

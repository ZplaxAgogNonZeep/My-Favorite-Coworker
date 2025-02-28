extends Node2D

class_name Device

enum DeviceAction {HOP, SHAKE}

@onready var originalPosn := position

@export_category("Node References")
@export var _gameArea : GameArea
@export_category("Movement Variables")
@export_range(0, 360) var shakeDegreeMax = PI
@export var hopHeight : Vector2
@export var hopDuration : float
@export_category("Modifiers")
@export var chatSpeed : float

var activeTween : Tween
var isContinuousShake := false
var isContinuousHop := false
var actionQueue : Array[DeviceAction] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	GameEvents.ShakeDeviceOnce.connect(shake)
	GameEvents.HopDeviceOnce.connect(hop)
	GameEvents.StartShakeDevice.connect(startShake)
	GameEvents.EndShakeDevice.connect(endShake)
	GameEvents.StartHopDevice.connect(startHop)
	GameEvents.endHopDevice.connect(endShake)


#region Device Controls

func turnOnDevice():
	_gameArea.startGame()

#endregion

#region Utility Functions

func getPetManager() -> PetManager:
	return _gameArea.petManager

#endregion

#region Device Animations

func checkQueue():
	if actionQueue.size() > 0:
		if actionQueue[actionQueue.size() - 1] == DeviceAction.SHAKE:
			actionQueue.remove_at(actionQueue.size() - 1)
			_shakeOnce()
		elif actionQueue[actionQueue.size() - 1] == DeviceAction.HOP:
			actionQueue.remove_at(actionQueue.size() - 1)
			_hopOnce()
		return false
	else:
		return true

#region Events

func hop():
	if not activeTween:
		isContinuousHop = false
		_hopOnce()
	else:
		actionQueue += [DeviceAction.HOP]

func shake():
	if not activeTween:
		isContinuousShake = false
		_shakeOnce()
		#shakeLeft()
	else:
		actionQueue += [DeviceAction.SHAKE]

func startShake():
	if not activeTween:
		isContinuousShake = true
		_shakeOnce()

func startHop():
	if not activeTween:
		isContinuousHop = true
		_hopOnce()

func endShake():
	pass

func endHop():
	pass
#endregion

#region Tween Controls 

func _shakeOnce(isStart : bool = true):
	if isStart:
		activeTween = get_tree().create_tween()
		activeTween.set_ease(Tween.EASE_IN)
		activeTween.set_trans(Tween.TRANS_BACK)
		activeTween.tween_property(self, 
									"rotation_degrees", 
									shakeDegreeMax * -1, 
									.5)
	else:
		activeTween = get_tree().create_tween()
		activeTween.set_ease(Tween.EASE_IN_OUT)
		activeTween.set_trans(Tween.TRANS_LINEAR)
		activeTween.tween_property(self, 
									"rotation_degrees", 
									shakeDegreeMax * -1, 
									.25)
	await activeTween.finished
	
	activeTween = get_tree().create_tween()
	activeTween.set_ease(Tween.EASE_IN_OUT)
	activeTween.set_trans(Tween.TRANS_LINEAR)
	activeTween.tween_property(self, 
								"rotation_degrees", 
								shakeDegreeMax, 
								.25)
	await activeTween.finished
	
	if (!isContinuousShake):
		activeTween = get_tree().create_tween()
		activeTween.set_ease(Tween.EASE_OUT)
		activeTween.set_trans(Tween.TRANS_BACK)
		activeTween.tween_property(self, 
									"rotation_degrees", 
									0, 
									.5)
		await activeTween.finished
	
	completeOneShake()


func _hopOnce():
	activeTween = get_tree().create_tween()
	activeTween.set_ease(Tween.EASE_OUT)
	activeTween.set_trans(Tween.TRANS_LINEAR)
	activeTween.tween_property(self, "position", position + hopHeight, 
								hopDuration * .5)
	await activeTween.finished
	
	activeTween = get_tree().create_tween()
	activeTween.set_ease(Tween.EASE_IN)
	activeTween.set_trans(Tween.TRANS_LINEAR)
	activeTween.tween_property(self, "position", originalPosn, 
								hopDuration * .5)
	await  activeTween.finished
	
	completedOneHop()


func completeOneShake():
	if isContinuousShake:
		_shakeOnce(false)
	else:
		_finishedShaking()


func _finishedShaking():
	if (checkQueue()):
		activeTween = null
		GameEvents.FinishedShakeDevice.emit()


func completedOneHop():
	if isContinuousHop:
		_hopOnce()
	else:
		_finishedHopping()

func _finishedHopping():
	if (checkQueue()):
		activeTween = null
		GameEvents.FinishedHopDevice.emit()

#endregion

#endregion

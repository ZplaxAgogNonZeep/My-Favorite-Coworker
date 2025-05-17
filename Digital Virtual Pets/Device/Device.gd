extends Node2D

class_name Device

enum DeviceAction {HOP, SHAKE}

@onready var originalPosn := position

@export_category("Node References")
@export var _gameArea : GameArea
@export var _animator : AnimationPlayer
@export var _movementGroup : Node2D
@export var _miniDevice : AnimatedSprite2D
@export_category("Movement Variables")
@export_range(0, 360) var shakeDegreeMax = PI
@export var hopHeight : Vector2
@export var hopDuration : float
@export var _minimizeShiftDistance : float
@export_category("Modifiers")
@export var chatSpeed : float

var activeTween : Tween
var isContinuousShake := false
var isContinuousHop := false
var actionQueue : Array[DeviceAction] = []
var _minHovered := false
var _waitingForMaximize := false

# Called when the node enters the scene tree for the first time.
func _ready():
	GameEvents.ShakeDeviceOnce.connect(shake)
	GameEvents.HopDeviceOnce.connect(hop)
	GameEvents.StartShakeDevice.connect(startShake)
	GameEvents.EndShakeDevice.connect(endShake)
	GameEvents.StartHopDevice.connect(startHop)
	GameEvents.endHopDevice.connect(endShake)
	GameEvents.DeviceRequestAttention.connect(_requestAttentionMode)


func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and _minHovered):
		if (event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()):
			toggleDeviceMinimize(false)

#region Device Controls

func turnOnDevice():
	_gameArea.startGame()


func _requestAttentionMode():
	if (Settings.minimized):
		_waitingForMaximize = true
		_miniDevice.play("NeedAttention")
	else:
		GameEvents.DeviceAttentionReceived.emit()


func toggleDeviceMinimize(isMinimized : bool):
	if (Settings.minimized == isMinimized):
		return
	
	Settings.minimized = isMinimized
	
	if (Settings.minimized):
		_animator.play("minimize_device")
		_miniDevice.play("ScreenOn")
	else:
		_animator.play("maximize_device")
		_miniDevice.play("ScreenOn")
		if (_waitingForMaximize):
			GameEvents.DeviceAttentionReceived.emit()
	
	_shiftDeviceOver()

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

func spawnDevice():
	# dialog here
	turnOnDevice()


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

func _shiftDeviceOver():
	var tween = create_tween()
	
	var direction = Settings.determineDeviceGrowDir()

	if (!Settings.minimized):
		direction *= -1
	var target = Vector2(_movementGroup.position.x + (
							(_minimizeShiftDistance * Settings.gameScale) * direction), 
						_movementGroup.position.y)
	tween.tween_property(_movementGroup, "position", 
						target, 
						_animator.current_animation_length).set_ease(
							Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	
	if (!Settings.minimized):
		Settings.toggleMinimizedWindow(Settings.minimized)
	
	await tween.finished
	if (Settings.minimized):
		Settings.toggleMinimizedWindow(Settings.minimized)


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

#region Node Signals

func _minDeviceMouseEntered() -> void:
	_minHovered = true


func _minDeviceMouseExited() -> void:
	_minHovered = false

#endregion

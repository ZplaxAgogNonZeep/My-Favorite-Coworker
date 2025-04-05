extends Node2D

class_name PseudoPet

var implements = []

signal AreaEntered
signal AreaExited
signal BodyEntered
signal BodyExited
signal TweenToFinished

enum MovePhase {IDLE, MOVING, HOPPING, INDICATING}

@onready var sprite = $AnimatedSprite2D

var phase : MovePhase = MovePhase.IDLE
var speed : float
var originalPosn : Vector2
var startPosn : Vector2
var endPosn : Vector2
var repetitions : int
var activeTween : Tween

func _process(delta):
	match phase:
		MovePhase.IDLE:
			pass
		MovePhase.MOVING:
			pass
		MovePhase.HOPPING:
			pass
		MovePhase.INDICATING:
			if position != endPosn:
				position = position.move_toward(endPosn, speed)
			else:
				var tempPosn = startPosn
				startPosn = endPosn
				endPosn = tempPosn

func tweenToLocation(posn : Vector2, speed : float):
	phase = MovePhase.MOVING
	if activeTween:
		activeTween.stop()
		position = originalPosn
	
	originalPosn = position
	startPosn = position
	endPosn = posn
	self.speed = speed
	
	activeTween = get_tree().create_tween()
	activeTween.set_ease(Tween.EASE_IN_OUT)
	activeTween.tween_property(self, "position", endPosn, speed).connect("finished", moveTweenComplete)

func moveTweenComplete():
	phase = MovePhase.IDLE
	activeTween = null
	TweenToFinished.emit()

func setAtLocation(posn : Vector2):
	position = posn
	originalPosn = posn


func hop(numberOfTimes : int = 1):
	if activeTween:
		activeTween.stop()
	self.speed = .1
	originalPosn = position
	repetitions = numberOfTimes
	endPosn = position + (Vector2.UP * 10)
	startPosn = position
	
	phase = MovePhase.HOPPING
	repetitions -= 1
	activeTween = get_tree().create_tween()
	activeTween.tween_property(self, "position", endPosn, speed).connect("finished", endHop)
	

func endHop():
	activeTween = get_tree().create_tween()
	activeTween.tween_property(self, "position", startPosn, speed).connect("finished", hopComplete)

func hopComplete():
	if repetitions > 0:
		if activeTween:
			activeTween.stop()
		await get_tree().create_timer(.7)
		activeTween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT)
		activeTween.tween_property(self, "position", endPosn, speed).connect("finished", endHop)
		repetitions -= 1
		
	else:
		phase = MovePhase.IDLE

func setDirection(isRight : bool):
	sprite.flip_h = isRight


func indicateDirection(isRight : bool):
	speed = .5
	originalPosn = position
	startPosn = position
	if isRight:
		setDirection(isRight)
		endPosn = position + (Vector2.RIGHT * 5)
		
	else:
		setDirection(isRight)
		endPosn = position + (Vector2.LEFT * 5)
	
	phase = MovePhase.INDICATING

func stopIndicatingDirection():
	phase = MovePhase.IDLE
	position = originalPosn

# Signals ==========================================================================================

func areaCollide(area : Area2D, isEnter : bool):
	if isEnter:
		AreaEntered.emit()
	else:
		AreaExited.emit()

func bodyCollide(body : Node2D, isEnter : bool):
	if isEnter:
		BodyEntered.emit()
	else:
		BodyExited.emit()

extends Node2D

var implements = []

enum MovePhase {IDLE, MOVING, HOPPING, INDICATING}

@onready var sprite = $AnimatedSprite2D

var phase : MovePhase = MovePhase.IDLE
var speed : float
var originalPosn : Vector2
var startPosn : Vector2
var endPosn : Vector2
var repetitions : int

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

func tweenToLocation(posn : Vector2, speed):
	pass


func setAtLocation(posn : Vector2):
	pass


func hop(numberOfTimes : int, speed : float):
	originalPosn = position
	repetitions = numberOfTimes
	endPosn = position + (Vector2.UP * 5)
	startPosn = position
	
	phase = MovePhase.HOPPING
	


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
	

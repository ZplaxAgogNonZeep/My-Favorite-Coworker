extends Node2D

const MAX_HUNGER : int = 100
const MAX_JOY : int = 100

@onready var gameArea = get_parent()
@onready var type := get_node_or_null("Type")
@onready var targetPosn : Vector2 = position
@onready var previousPosn := position
@onready var defaultPosition := position

@export var leftBoundry : Marker2D
@export var rightBoundry : Marker2D
@export var sprite : AnimatedSprite2D
@export var roamSpeed := .1

var hungerValue : int = 100
var joyValue : int = 100

var menuMode : bool = false
var isRoaming := false




# Called when the node enters the scene tree for the first time.
func _ready():
	#goToPosition(gameArea.leftBoundry.position)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not menuMode:
		if (targetPosn):
			if (targetPosn.x > rightBoundry.position.x):
				targetPosn.x = rightBoundry.position.x
			if (targetPosn.x < leftBoundry.position.x):
				targetPosn.x = leftBoundry.position.x
			
			if (position.x != targetPosn.x):
				if not isRoaming:
					isRoaming = true
				
				position -= (position - targetPosn).normalized() * roamSpeed
				
				if (position.x < previousPosn.x and sprite.flip_h):
					sprite.flip_h = false
				elif (position.x > previousPosn.x and not sprite.flip_h):
					sprite.flip_h = true
			else:
				isRoaming = false
		
		
		
		type.roamBehavior()
		previousPosn = position

func getNextPosition():
	var RightMostPosn = position.x + 48
	var LeftMostPosn = position.x - 48
	
	if (RightMostPosn > rightBoundry.position.x):
		RightMostPosn = rightBoundry.position.x
	if (LeftMostPosn < leftBoundry.position.x):
		LeftMostPosn = leftBoundry.position.x
	randomize()
	return Vector2(randi_range(RightMostPosn, LeftMostPosn), position.y)

func goToPosition(posn : Vector2):
	if menuMode:
		position = posn
	else:
		targetPosn = posn

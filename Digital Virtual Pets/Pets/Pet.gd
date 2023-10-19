extends Node2D

const MAX_HUNGER : int = 100
const MAX_JOY : int = 100

@onready var gameArea = get_parent()
@onready var type := get_node_or_null("Type")
@onready var targetPosn : Vector2 = position
@onready var previousPosn := position
@onready var defaultPosition := position

@export_category("Object References")
@export var leftBoundry : Marker2D
@export var rightBoundry : Marker2D
@export var sprite : AnimatedSprite2D
# These two should probably be moved to being instanced when the pet is spawned in
@export var hungerBar : Node2D
@export var joyBar : Node2D
@export_category("Pet Values")
@export var roamSpeed := .5
@export var personality : Enums.Personality
@export var abilityStats : Dictionary = {
	Enums.AbilityStat.POW: 0, 
	Enums.AbilityStat.END: 0,
	Enums.AbilityStat.SPD: 0,
	Enums.AbilityStat.BAL: 0}

# Order of Stats follow order in enum:
# [POW, END, SPD, BAL]
var personalityModifiers : Dictionary = {
	Enums.Personality.MEAN : [1,1,0,-1],
	Enums.Personality.CALM : [-1,0,1,1],
	Enums.Personality.FOCUSED : [0,1,-1,1],
	Enums.Personality.AIRHEAD : [0,0,0,0]
}

var hungerValue : int = 100
var joyValue : int = 100
var petState := Enums.PetState.ROAMING

#var menuMode := false
var isRoaming := false


func _ready():
	GameEvents.TickHunger.connect(tickHunger)
	GameEvents.TickJoy.connect(tickJoy)
	Enums.Personality.values()


func _process(delta):
	if petState == Enums.PetState.ROAMING:
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


func tickHunger():
	type.onTickHunger()
	randomize()
	hungerValue -= randi_range(1, 5)
	hungerBar.updateBar(hungerValue, MAX_HUNGER)


func tickJoy():
	type.onTickJoy()
	randomize()
	joyValue -= randi_range(0, 5)
	joyBar.updateBar(joyValue, MAX_JOY)


# Utility Functions ================================================================================

func personalityMod(statToIncrease : Enums.AbilityStat, value):
	var modifiedValue = value + personalityModifiers[personality][statToIncrease]
	return modifiedValue


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
	if petState == Enums.PetState.MENU:
		position = posn
	elif petState == Enums.PetState.ROAMING:
		targetPosn = posn

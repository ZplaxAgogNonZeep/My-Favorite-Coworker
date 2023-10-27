extends Node2D

const MAX_HUNGER : int = 100
const MAX_JOY : int = 100

const personalityModifiers : Dictionary = {
	Enums.Personality.MEAN : [1,1,0,-1],
	Enums.Personality.CALM : [-1,0,1,1],
	Enums.Personality.FOCUSED : [0,1,-1,1],
	Enums.Personality.AIRHEAD : [0,0,0,0]
	}# Order of Stats follow order in enum: [POW, END, SPD, BAL]

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
	Enums.AbilityStat.BAL: 0
	}

var hungerValue : int = 100
var joyValue : int = 100
var petState := Enums.PetState.ROAMING
var stateOnUnpause : Enums.PetState
var isRoaming := false
var isFoodReached := false
var traumaCount := 0

func _ready():
	GameEvents.TickHunger.connect(tickHunger)
	GameEvents.TickJoy.connect(tickJoy)
	GameEvents.FoodPlaced.connect(feedPet)
	GameEvents.PauseGame.connect(gamePaused)
	GameEvents.UnpauseGame.connect(gameUnpaused)
	
	hungerBar.updateBar(hungerValue, MAX_HUNGER)
	joyBar.updateBar(joyValue, MAX_JOY)


func _process(delta):
	if petState == Enums.PetState.ROAMING:
		if (targetPosn):
			alineToBoundry()
			
			if (position.x != targetPosn.x):
				if not isRoaming:
					isRoaming = true
				
				position -= (position - targetPosn).normalized() * roamSpeed
			else:
				isRoaming = false
		
		type.roamBehavior()
		setSpriteDirection()
		previousPosn = position
		
	elif petState == Enums.PetState.FEEDING:
		type.feedingBehavior()


func eatFood(foodObject):
	petState = Enums.PetState.FEEDING
	await get_tree().create_timer(2).timeout
	type.onEatFood()
	hungerValue += foodObject.feedAmount
	
	if hungerValue > MAX_HUNGER:
		hungerValue = MAX_HUNGER
	
	hungerBar.updateBar(hungerValue, MAX_HUNGER)
	
	foodObject.queue_free()
	targetPosn = position
	petState = Enums.PetState.ROAMING
	
	GameEvents.UnpauseTimers.emit()


# Events ===========================================================================================

func gamePaused():
	stateOnUnpause = petState
	petState = Enums.PetState.MENU

func gameUnpaused():
	petState = stateOnUnpause

func feedPet():
	if (get_tree().get_nodes_in_group("Food").size() > 0):
		if (not isFoodReached):
			GameEvents.PauseTimers.emit()
			await get_tree().create_timer(2).timeout
			targetPosn = get_tree().get_nodes_in_group("Food")[0].position
	else:
		petState = Enums.PetState.ROAMING


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

func pauseAllTimers():
	pass

func alineToBoundry():
	if (targetPosn.x > rightBoundry.position.x):
		targetPosn.x = rightBoundry.position.x
	if (targetPosn.x < leftBoundry.position.x):
		targetPosn.x = leftBoundry.position.x


func setSpriteDirection():
	if (position.x < previousPosn.x and sprite.flip_h):
		sprite.flip_h = false
	elif (position.x > previousPosn.x and not sprite.flip_h):
		sprite.flip_h = true


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

# Collision Singals ===================================================================================

func objectCollisionEnter(area):
	if area.get_parent().implements.has(Interface.Food):
		isFoodReached = true
		eatFood(area.get_parent())

func objectCollisionExit(area):
	if area.get_parent().implements.has(Interface.Food):
		isFoodReached = false

func _on_left_object_coll_area_entered(area):
	objectCollisionEnter(area)


func _on_right_object_coll_area_entered(area):
	objectCollisionEnter(area)


func _on_left_object_coll_area_exited(area):
	objectCollisionExit(area)

func _on_right_object_coll_area_exited(area):
	objectCollisionExit(area)

extends Node2D

const MAX_HUNGER : int = 100
const MAX_JOY : int = 100

const TRAUMA_INTERVALS : Array[int] = [10, 10, 10, 10, 10] # [60, 50, 40, 30, 20]

const personalityModifiers : Dictionary = {
	Enums.Personality.MEAN : [1,1,0,-1],
	Enums.Personality.CALM : [-1,0,1,1],
	Enums.Personality.FOCUSED : [0,1,-1,1],
	Enums.Personality.AIRHEAD : [0,0,0,0]
	}# Order of Stats follow order in enum: [POW, END, SPD, BAL]

@onready var petManager = get_parent()
@onready var type := get_node_or_null("Type")
@onready var targetPosn : Vector2 = position
@onready var previousPosn := position
@onready var defaultPosition := position

@export_category("Object References")
@export var sprite : AnimatedSprite2D
@export var leftCollider : Area2D
@export var rightCollider : Area2D
@export_category("Pet Values")
@export var evolvesTo : Array[PackedScene]
@export var roamSpeed := .5
@export_category("Misc References")
@export var iconSprite : Texture2D

var evolvedFromIcons : Array # Transfered

var abilityStats : Dictionary = { # Transfered
	Enums.AbilityStat.POW: 0, 
	Enums.AbilityStat.END: 0,
	Enums.AbilityStat.SPD: 0,
	Enums.AbilityStat.BAL: 0
	}
var personality : Enums.Personality # Transfered
var hungerValue : int = 100 # Transfered
var joyValue : int = 100 # Transfered
var traumaCount := 0 # Transfered

var petState := Enums.PetState.ROAMING
var stateOnUnpause : Enums.PetState
var isRoaming := false
var isFoodReached := false

func _ready():
	GameEvents.TickHunger.connect(tickHunger)
	GameEvents.TickJoy.connect(tickJoy)
	GameEvents.FoodPlaced.connect(feedPet)
	GameEvents.EvolveCheck.connect(evolvePet)
	GameEvents.PauseGame.connect(gamePaused)
	GameEvents.UnpauseGame.connect(gameUnpaused)
	
	petManager.hungerBar.updateBar(hungerValue, MAX_HUNGER)
	petManager.joyBar.updateBar(joyValue, MAX_JOY)


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
	
	petManager.hungerBar.updateBar(hungerValue, MAX_HUNGER)
	
	foodObject.queue_free()
	targetPosn = position
	petState = Enums.PetState.ROAMING
	
	GameEvents.UnpauseTimers.emit()

func startNeglectTimer():
	if traumaCount > 5:
		traumaCount = 5
	
	if $Type/NeglectTimer.time_left == 0:
		print("Neglect Timer called at trauma ", traumaCount)
		$Type/NeglectTimer.start(TRAUMA_INTERVALS[traumaCount])


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
	if (hungerValue > 0):
		type.onTickHunger()
		randomize()
		hungerValue -= randi_range(1, 5)
		
		if hungerValue <= 0:
			hungerValue = 0
			traumaCount += 1
			startNeglectTimer()
		
		petManager.hungerBar.updateBar(hungerValue, MAX_HUNGER)


func tickJoy():
	if (joyValue > 0):
		type.onTickJoy()
		randomize()
		joyValue -= randi_range(0, 5)
		if joyValue <= 0:
			joyValue = 0
			traumaCount += 1
			startNeglectTimer()
		petManager.joyBar.updateBar(joyValue, MAX_JOY)

func neglectTimeout():
	print("Neglect timedout with trauma at ", traumaCount)
	if hungerValue <= 0 or joyValue <= 0:
		traumaCount += 1
		if traumaCount > 5:
			GameEvents.PetDied.emit()
		else:
			$Type/NeglectTimer.start(TRAUMA_INTERVALS[traumaCount - 1])

func evolvePet():
	print("Evolve singal received")
	if (type.getEvolvePet() != null):
		petManager.evolvePet(type.getEvolvePet())

# Utility Functions ================================================================================

func pauseAllTimers():
	pass

func alineToBoundry():
	if (targetPosn.x > petManager.rightBoundry.position.x):
		targetPosn.x = petManager.rightBoundry.position.x
	if (targetPosn.x < petManager.leftBoundry.position.x):
		targetPosn.x = petManager.leftBoundry.position.x


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
	
	if (RightMostPosn > petManager.rightBoundry.position.x):
		RightMostPosn = petManager.rightBoundry.position.x
	if (LeftMostPosn < petManager.leftBoundry.position.x):
		LeftMostPosn = petManager.leftBoundry.position.x
	randomize()
	return Vector2(randi_range(RightMostPosn, LeftMostPosn), position.y)


func goToPosition(posn : Vector2):
	if petState == Enums.PetState.MENU:
		position = posn
	elif petState == Enums.PetState.ROAMING:
		targetPosn = posn

# Getters and Setters



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

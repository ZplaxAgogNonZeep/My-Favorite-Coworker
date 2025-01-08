extends Node2D

class_name Pet

signal UpdateStatusBars(hungerValue, joyValue)
signal ReadyToEvolve(evolvedForm)

const MAX_HUNGER : int = 100
const MAX_JOY : int = 100

const TRAUMA_INTERVALS : Array[int] = [60, 50, 40, 30, 20] # [60, 50, 40, 30, 20]
const EVOLVE_INTERVALS : Array[int] = [60, 120, 210, 600]

const personalityModifiers : Dictionary = {
	Enums.Personality.MEAN : [1,1,0,-1],
	Enums.Personality.CALM : [-1,0,1,1],
	Enums.Personality.FOCUSED : [0,1,-1,1],
	Enums.Personality.AIRHEAD : [0,0,0,0]
	}# Order of Stats follow order in enum: [POW, END, SPD, BAL]

#@onready var petManager = get_parent()
@onready var type : PetType = get_node_or_null("Type")
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
var boundries : Array[Vector2] # Transfered

#TODO: Reset food on evolve
var _objectsInRange : Array = []
var _foodQueue : Array = [] 
var _overfed := false

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
	GameEvents.FoodPlaced.connect(foodPlaced)
	GameEvents.EvolveCheck.connect(evolvePet)
	GameEvents.PauseGame.connect(gamePaused)
	GameEvents.UnpauseGame.connect(gameUnpaused)
	
	UpdateStatusBars.emit(hungerValue, joyValue)
	


func _process(delta):
	if petState == Enums.PetState.ROAMING:
		if (isRoaming):
			if (sprite.animation != "Walk"):
				sprite.play("Walk")
		else:
			if (sprite.animation != "Idle"):
				sprite.play("Idle")
		
		
		if (targetPosn):
			#alineToBoundry()
			
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
		if (sprite.animation != "Quirk"):
			sprite.play("Quirk")
		type.feedingBehavior()
	elif petState == Enums.PetState.EVOLVING:
		pass


func eatFood(foodObject):
	print("call eat food")
	# Sets state to FEEDING to stop any roaming, faces the food, then waits while it eats.
	petState = Enums.PetState.FEEDING
	setSpriteDirection(foodObject.position.x < position.x)
	await get_tree().create_timer(2).timeout
	print("Finished eat yield")
	
	# Performs whatever unique thing the pet does when eating, then adds the hunger value
	type.onEatFood()
	hungerValue += foodObject.feedAmount
	
	if hungerValue > MAX_HUNGER:
		hungerValue = MAX_HUNGER
	
	UpdateStatusBars.emit(hungerValue, joyValue)
	
	# Updates the associated lists and queues
	_foodQueue.erase(foodObject)
	_objectsInRange.erase((foodObject))
	foodObject.queue_free()
	
	# Then decide what to do next
	if (_foodQueue.size() > 0):
		# There's more food to eat, so either eat whats already in range or find the next one
		if (_objectsInRange.size() > 0):
			eatFood(_objectsInRange[0])
		else:
			targetPosn = _foodQueue[0].position
			petState = Enums.PetState.ROAMING
	else:
		# no more food! move on from feeding time
		targetPosn = position
		petState = Enums.PetState.ROAMING
		
		GameEvents.UnpauseTimers.emit()
	
	

func receivePlay(joyIncrement : int, statToIncrease : Enums.AbilityStat, statIncrease : int):
	joyValue += joyIncrement
	
	if joyValue > MAX_JOY:
		joyValue = MAX_JOY
	
	abilityStats[statToIncrease] += personalityMod(statToIncrease, statIncrease)

func startNeglectTimer():
	if traumaCount > 5:
		traumaCount = 5
	
	if $Type/NeglectTimer.time_left == 0:
		print("Neglect Timer called at trauma ", traumaCount)
		$Type/NeglectTimer.start(TRAUMA_INTERVALS[traumaCount])

#region Events 

func foodPlaced(food):
	if (_foodQueue.has(food)):
		print("WARNING: Pet has received a signal for a food object it's already gotten before")
		return
	
	if (_foodQueue.size() == 0):
		if (not isFoodReached):
			_foodQueue.append(food)
			GameEvents.PauseTimers.emit()
			await get_tree().create_timer(2).timeout
			targetPosn = food.position
	else:
		_foodQueue.append(food)
		if (_foodQueue.size() > 3 and not _overfed):
			_overfed = true
			neglectTimeout(true)

func gamePaused():
	stateOnUnpause = petState
	petState = Enums.PetState.MENU


func gameUnpaused():
	petState = stateOnUnpause


func tickHunger():
	if (hungerValue > 0):
		
		if (hungerValue < 25):
			GameEvents.HopDeviceOnce.emit()
		type.onTickHunger()
		randomize()
		hungerValue -= randi_range(1, 5)
		
		if hungerValue <= 0:
			hungerValue = 0
			traumaCount += 1
			startNeglectTimer()
		
		UpdateStatusBars.emit(hungerValue, joyValue)


func tickJoy():
	if (joyValue > 0):
		if joyValue < 10:
			GameEvents.HopDeviceOnce.emit()
		type.onTickJoy()
		randomize()
		joyValue -= randi_range(0, 5)
		if joyValue <= 0:
			joyValue = 0
			traumaCount += 1
			startNeglectTimer()
		UpdateStatusBars.emit(hungerValue, joyValue)


func neglectTimeout(skipValueCheck := false):
	print("Neglect timedout with trauma at ", traumaCount)
	if hungerValue <= 0 or joyValue <= 0 or skipValueCheck:
		traumaCount += 1
		if traumaCount > 5:
			GameEvents.PetDied.emit()
		else:
			$Type/NeglectTimer.start(TRAUMA_INTERVALS[traumaCount - 1])

func evolvePet():
	print("Evolve singal received")
	if (type.getEvolvePet() != null):
		petState = Enums.PetState.EVOLVING
		sprite.play("Quirk")
		ReadyToEvolve.emit(type.getEvolvePet())
		#petManager.evolvePet(type.getEvolvePet())

#endregion

#region Utility Functions 

func pauseAllTimers():
	pass

func alineToBoundry():
	if (targetPosn.x > boundries[1].x):
		targetPosn.x = boundries[1].x
	if (targetPosn.x < boundries[0].x):
		targetPosn.x = boundries[0].x


func setSpriteDirection(overrideDirection := false, direction := false):
	if (overrideDirection):
		sprite.flip_h = direction
	elif (position.x < previousPosn.x and sprite.flip_h):
		sprite.flip_h = false
	elif (position.x > previousPosn.x and not sprite.flip_h):
		sprite.flip_h = true


func personalityMod(statToIncrease : Enums.AbilityStat, value):
	var modifiedValue = value + personalityModifiers[personality][statToIncrease]
	if modifiedValue < 0:
		modifiedValue = 0
	return modifiedValue


func getNextPosition():
	var RightMostPosn = position.x + 48
	var LeftMostPosn = position.x - 48
	
	if (RightMostPosn > boundries[1].x):
		RightMostPosn = boundries[1].x
	if (LeftMostPosn < boundries[0].x):
		LeftMostPosn = boundries[0].x
	randomize()
	return Vector2(randi_range(RightMostPosn, LeftMostPosn), position.y)


func goToPosition(posn : Vector2):
	if petState == Enums.PetState.MENU:
		position = posn
	elif petState == Enums.PetState.ROAMING:
		targetPosn = posn


func getSpriteIcon() -> Texture2D:
	return sprite.sprite_frames.get_frame_texture("Idle", 0)

func getSpriteOffset() -> float:
	return sprite.offset.y

#endregion

#region Collision Singals 

func _objectAreaCollisionEnter(area):
	pass
	#if (Interface.hasInterface(area, Interface.Food)):
		#isFoodReached = true
		#eatFood(area)

func _objectAreaCollisionExit(area):
	pass
	#if (Interface.hasInterface(area, Interface.Food)):
		#isFoodReached = false

func _objectBodyCollisionEnter(body):
	if (Interface.hasInterface(body, Interface.Food) and petState != Enums.PetState.FEEDING):
		if (not _objectsInRange.has(body)):
			_objectsInRange.append(body)
		isFoodReached = true
		eatFood(body)
	elif (Interface.hasInterface(body, Interface.Food) and not _objectsInRange.has(body)):
		_objectsInRange.append(body)

func _objectBodyCollisionExit(body):
	if (Interface.hasInterface(body, Interface.Food) and petState != Enums.PetState.FEEDING):
		if (_objectsInRange.has(body)):
			_objectsInRange.erase(body)
		isFoodReached = false

#endregion

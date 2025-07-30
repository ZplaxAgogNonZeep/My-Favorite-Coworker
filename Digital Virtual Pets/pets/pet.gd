extends Node2D

class_name Pet

class PetSaveData extends SaveData.SavableClass:
	var petResource
	var personality
	var hungerValue
	var joyValue
	var traumaCount
	var evolvedFromIcons
	var abilityStats
	var age

signal UpdateStatusBars(hungerValue, joyValue)
signal UpdateStatRecord(petData : PetTypeData, evoStatArray : Array)
signal ReadyToEvolve(evolvedForm)

const STAT_MAX : int = 99
const MAX_HUNGER : int = 100
const MAX_JOY : int = 100
const TRAUMA_INTERVALS : Array[int] = [60, 50, 40, 30, 20]
const EVOLVE_INTERVALS : Array[int] = [60, 1800, 3600, 8000]
## A note on timer intervals and their intentions
## Now that I've implemented a way to force evolution checks, I'm going to leave the intervals 
## in a close to final state. Testing will probably need to be done to figure out what feels right
## but the general thought process is as follows:
## - Evolution checks will take longer the higher stage a pet is, starting at a couple minutes for
## the eggs, half hour for the stage one, a full hour for stage two's and somewhere in the hour
## two hour range for stage three's. Stat gain requirements will also need to match what you can 
## make in that amount of time, plus some extra for the late stages
## - Trauma checks should get faster the more you obtain, giving some leeway for first-time offenders
## while quickly punishing players who let it go for too long.

const personalityModifiers : Dictionary = {
	Enums.Personality.MEAN : [1,1,0,-1],
	Enums.Personality.CALM : [-1,0,1,1],
	Enums.Personality.FOCUSED : [0,1,-1,1],
	Enums.Personality.AIRHEAD : [0,0,0,0]
	}# Order of Stats follow order in enum: [POW, END, SPD, BAL]

@onready var targetPosn : Vector2 = position
@onready var previousPosn := position
@onready var defaultPosition := position

@export_category("Object References")
@export var sprite : AnimatedSprite2D
@export var leftCollider : Area2D
@export var rightCollider : Area2D
@export var _moveTimer : Timer
@export var _neglectTimer : Timer
@export var _lifespanTracker: Lifespan

@export_category("Pet Values")
@export var roamSpeed := .5
@export_range(0, 1.0) var roamPercentage : float

#region Saved Variables
var petResource : PetTypeData #Saved
var personality : Enums.Personality # Saved
var hungerValue : int = 100 # Saved
var joyValue : int = 100 # Saved
var traumaCount := 0 # Saved
var evolvedFromIcons : Array # Saved
var abilityStats : Dictionary = { # Saved
	Enums.AbilityStat.POW: 0, 
	Enums.AbilityStat.END: 0,
	Enums.AbilityStat.SPD: 0,
	Enums.AbilityStat.BAL: 0
	}
#endregion
var petState := Enums.PetState.ROAMING
var stateOnUnpause : Enums.PetState
var isRoaming := false
var isFoodReached := false
var boundries : Array[Vector2] # Unsure

var _objectsInRange : Array = []
var _foodQueue : Array = [] 
var _overfed := false
var _nextAnimation : String
var _feedingFrames := 0.0

func _ready():
	GameEvents.TickHunger.connect(tickHunger)
	GameEvents.TickJoy.connect(tickJoy)
	GameEvents.FoodPlaced.connect(foodPlaced)
	GameEvents.EvolveCheck.connect(evolvePet)
	GameEvents.PauseGame.connect(gamePaused)
	GameEvents.UnpauseGame.connect(gameUnpaused)
	
	_moveTimer.connect("timeout", _onMoveTimerTimeout)
	
	UpdateStatusBars.emit(hungerValue, joyValue)


func _process(delta):
	#if (Input.is_action_just_pressed("Debug2")):
		#GameEvents.PetDied.emit()
	if (petResource.stage == 0):
		return
	if petState == Enums.PetState.ROAMING:
		if (isRoaming):
			if (sprite.animation != "Walk"):
				_setNextAnimation("Walk")
				#sprite.play("Walk")
				
		else:
			if (sprite.animation != "Idle"):
				_setNextAnimation("Idle")
				#sprite.play("Idle")
		
		
		if (targetPosn):
			targetPosn = alineToBoundry(targetPosn)
			
			if (position.x != targetPosn.x):
				if not isRoaming:
					isRoaming = true
				var lastPosn = position
				position -= (position - targetPosn).normalized() * roamSpeed
				if ((lastPosn.x < targetPosn.x and position.x > targetPosn.x) 
						or 
					(lastPosn.x > targetPosn.x and position.x < targetPosn.x)):
					
					position = targetPosn
			else:
				isRoaming = false
		
		#type.roamBehavior()
		if not isRoaming and _moveTimer.is_stopped():
			randomize()
			_moveTimer.start(randf_range(petResource.waitIntervals.x, petResource.waitIntervals.y))
		
		setSpriteDirection()
		
	elif petState == Enums.PetState.FEEDING:
		if (sprite.animation != "Quirk"):
			sprite.play("Quirk")
		_feedingFrames += delta
		if (_feedingFrames > 60):
			_feedingFrames = 0
			targetPosn = position
			petState = Enums.PetState.ROAMING
			GameEvents.UnpauseTimers.emit()
	elif petState == Enums.PetState.EVOLVING:
		pass
	
	previousPosn = position


func loadResourceData():
	var lastAnim = sprite.animation
	sprite.sprite_frames = petResource.spriteFrames
	sprite.offset.y = petResource.getSpriteOffset()
	leftCollider.position.x = petResource.getCollisionOffset() * -1
	rightCollider.position.x = petResource.getCollisionOffset()
	sprite.play(lastAnim)

#region Behavior Functions
func eatFood(foodObject):
	# Sets state to FEEDING to stop any roaming, faces the food, then waits while it eats.
	petState = Enums.PetState.FEEDING
	setSpriteDirection(foodObject.position.x < position.x)
	foodObject.startEating()
	await foodObject.FinishedEating
	
	# Performs whatever unique thing the pet does when eating, then adds the hunger value
	#type.onEatFood()
	hungerValue += foodObject.feedAmount
	
	if hungerValue > MAX_HUNGER:
		if (hungerValue >= 175):
			traumaCount += 1
			if traumaCount > 5:
				GameEvents.PetDied.emit()
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
	
	SfxManager.playSoundEffect(petResource.yap)


func receivePlay(joyIncrement : int, statToIncrease : Enums.AbilityStat, statIncrease : int):
	joyValue += joyIncrement
	
	if joyValue > MAX_JOY:
		if (joyValue >= 175):
			traumaCount += 1
			if traumaCount > 5:
				GameEvents.PetDied.emit()
		joyValue = MAX_JOY
	
	UpdateStatusBars.emit(hungerValue, joyValue)
	
	abilityStats[statToIncrease] += personalityMod(statToIncrease, statIncrease)
	_evoStatsUpdated()
	
	SfxManager.playSoundEffect(petResource.yap)
	SaveData.saveGameToFile()
#endregion

#region Events 
func gamePaused():
	stateOnUnpause = petState
	petState = Enums.PetState.MENU


func gameUnpaused():
	petState = stateOnUnpause


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


func tickHunger():
	if (hungerValue > 0):
		
		if (hungerValue < 25):
			GameEvents.HopDeviceOnce.emit()
		#type.onTickHunger()
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
		#type.onTickJoy()
		randomize()
		joyValue -= randi_range(1, 3)
		if joyValue <= 0:
			joyValue = 0
			traumaCount += 1
			startNeglectTimer()
		UpdateStatusBars.emit(hungerValue, joyValue)


func neglectTimeout(skipValueCheck := false):
	print("Neglect timedout with trauma at ", traumaCount)
	SfxManager.playSoundEffect(petResource.yap)
	if hungerValue <= 0 or joyValue <= 0 or skipValueCheck:
		traumaCount += 1
		if traumaCount > 5:
			GameEvents.PetDied.emit()
		else:
			_neglectTimer.start(TRAUMA_INTERVALS[traumaCount - 1] * Settings.getTimerMod())

func evolvePet():
	print("Evolve Check")
	if (petResource.getNextEvolution(self) != null):
		SfxManager.playSoundEffect(petResource.yap)
		petState = Enums.PetState.EVOLVING
		if (petResource.stage != 0):
			sprite.play("Quirk")
		ReadyToEvolve.emit(petResource.getNextEvolution(self))
		#petManager.evolvePet(type.getEvolvePet())

#endregion

#region Utility Functions 
func pauseAllTimers():
	pass


func _setNextAnimation(animationName : String):
	if (_nextAnimation == animationName):
		return
	_nextAnimation = animationName
	await sprite.animation_looped
	sprite.play(_nextAnimation)
	_nextAnimation = ""

## Called when the pet updates any stats involved in evolution, including ability stats, 
## trauma, and personality. ordered as such:
## 0 = POW
## 1 = END
## 2 = SPD
## 3 = BAL
## 4 = Trauma
## 5 = Stat Total
func _evoStatsUpdated() -> void:
	var evoStatArray : Array = [abilityStats[Enums.AbilityStat.POW], abilityStats[Enums.AbilityStat.END],
								abilityStats[Enums.AbilityStat.SPD], abilityStats[Enums.AbilityStat.BAL],
								traumaCount, getStatTotal()]
	UpdateStatRecord.emit(petResource, evoStatArray)


func getRawAge() -> float:
	return _lifespanTracker.getLifespan()


func setRawAge(age : float) -> void:
	_lifespanTracker.setLifespan(age)


func getStatTotal() -> int:
	var returnInt : int
	for stat in abilityStats:
		returnInt += stat
	return returnInt


func getSavableData() -> PetSaveData:
	var data = PetSaveData.new()
	data.age = getRawAge()
	for property : Dictionary in data.get_property_list():
			if (property["name"] == "Built-in script" or property["name"] == "RefCounted" 
				or property["name"] == "script"or property["name"] == "age"):
				continue
			data.set(property["name"], get(property["name"]))
	
	return data


func setSavableData(data : PetSaveData) -> void:
	for property : Dictionary in data.get_property_list():
			if (property["name"] == "Built-in script" or property["name"] == "RefCounted" 
				or property["name"] == "script"):
				continue
			if (property["name"] == "age" and data.get(property["name"]) != null):
				_lifespanTracker.setLifespan(data.get(property["name"]))
			else:
				set(property["name"], data.get(property["name"]))

# Adjusts a given position's x value to fit within the game's boundry
func alineToBoundry(posn : Vector2) -> Vector2:
	var xBoundries = Vector2(PetManager.instance.percentToPosn(Vector2.ZERO).x, 
							PetManager.instance.percentToPosn(Vector2.ONE).x)
	var returnPosn := posn
	
	if (posn.x > xBoundries.y):
		returnPosn.x = xBoundries.y
	if (posn.x < xBoundries.x):
		returnPosn.x = xBoundries.x
	
	return returnPosn
	

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
	var RightMostPosn = PetManager.instance.addPercentToPosn(position, Vector2(roamPercentage, 0)).x
	var LeftMostPosn = PetManager.instance.addPercentToPosn(position, Vector2(-1 * roamPercentage, 0)).x
	
	RightMostPosn = alineToBoundry(Vector2(RightMostPosn, position.y)).x
	LeftMostPosn = alineToBoundry(Vector2(LeftMostPosn, position.y)).x

	randomize()
	var posn = randf_range(LeftMostPosn, RightMostPosn)
	return Vector2(posn, position.y)


func goToPosition(posn : Vector2):
	if petState == Enums.PetState.MENU:
		position = posn
	elif petState == Enums.PetState.ROAMING:
		targetPosn = posn


func startNeglectTimer():
	if traumaCount > 5:
		traumaCount = 5
	
	if _neglectTimer.time_left == 0:
		print("Neglect Timer called at trauma ", traumaCount)
		_neglectTimer.start(TRAUMA_INTERVALS[traumaCount] * Settings.getTimerMod())


func getSpriteIcon() -> Texture2D:
	return petResource.getSpriteIcon()

func getSpriteOffset() -> float:
	return petResource.getSpriteOffset()

#endregion

#region Node Signals 

func _onMoveTimerTimeout() -> void:
	goToPosition(getNextPosition())


func _objectAreaCollisionEnter(area):
	pass


func _objectAreaCollisionExit(area):
	pass


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

extends Node2D

class_name PetManager

var implements = []

static var instance : PetManager = self

class DataSaver extends SaveData.DataSaver:
	func getCategoryName():
		return "PetManager"
	var _petSlots
	var _slotIndex
	var _encounteredPets
	var _availableEggs
	var _statRecords
	var _statusRecords
	
	func getDataToSave() -> Data:
		obj.gatherDataFromActivePet()
		return super()

const MAX_PET_SLOTS := 3
const EGG_DATA_PATH := "res://data/pet_resources/stage_0/"

signal CallPetDeathScreen(petData : Dictionary)
signal WaitingForStopGap
signal _PassStopGap

@export_category("Object References")
@export var hungerBar : StatusBar
@export var joyBar : StatusBar
@export var leftBoundry : Marker2D
@export var rightBoundry : Marker2D
@export var animationManager : AnimationPlayer
@export_category("Pet References")
@export var respawnPet : PackedScene
@export var petSpawnPoint : Marker2D
@export var petStartResource : PetTypeData
@export_category("Pet Evolution Variables")
@export var _evolvingPet : EvolvingPet
@export var _evolveSequenceRate : float

var activePet : Pet
var _petSlots = []
var _slotIndex : int
var _boundryDistance : Vector2

var _encounteredPets : Dictionary[String, PetTypeData]
var _statRecords : Dictionary[PetTypeData, Array]
var _statusRecords : Dictionary[PetTypeData, Array]
var _availableEggs : Array[PetTypeData]

# Called when the node enters the scene tree for the first time.
func _ready():
	GameEvents.PetDied.connect(killPet)
	GameEvents.ChangePet.connect(switchPet)
	GameEvents.UnlockNewEgg.connect(_unlockNewEgg)
	PetManager.instance = self
	_boundryDistance = Vector2(rightBoundry.position.x - leftBoundry.position.x, 
								rightBoundry.position.y - leftBoundry.position.y)


## Used to convert percentage positions to local positions
func percentToPosn(percentPosn : Vector2) -> Vector2:
	return Vector2(lerpf(leftBoundry.position.x, rightBoundry.position.x, percentPosn.x), 
			lerpf(leftBoundry.position.y, rightBoundry.position.y, percentPosn.y))

## converts a local position to a percentage position
func posnToPercent(posn : Vector2) -> Vector2:
	var posnDistance = Vector2(posn.x - leftBoundry.position.x, posn.y - leftBoundry.position.y)
	return Vector2(posnDistance.x / _boundryDistance.x, posnDistance.y / _boundryDistance.y)

## take a position and increment it by the percent given
func addPercentToPosn(posn : Vector2, percentPosn : Vector2) -> Vector2:
	return percentToPosn(posnToPercent(posn) + percentPosn)


#region Pet Spawning & Evolving
func spawnPet(index := -1, isNewPet := false, petData : PetTypeData = null, givenName := ""):
	if (index >= MAX_PET_SLOTS):
		return
	
	var newPet = respawnPet.instantiate()
	newPet.position = petSpawnPoint.position
	
	# Load pet data from slots if applicable, otherwise use current slot, all else
	# fails it will create a brand new one
	# TODO: Update this for egg selection
	if (_petSlots.size() <= 0):
		_petSlots.append({})
		_slotIndex = 0
		newPet.personality = randi_range(0, Enums.Personality.values().size() - 1)
		if petData != null:
			newPet.petResource = petData
		else:
			newPet.petResource = _availableEggs[0]
		newPet.givenName = givenName
	elif (index < 0 and not isNewPet):
		newPet.setSavableData(loadPetDataFromSlot(_slotIndex))
	elif (index < _petSlots.size() and index >= 0):
		if (isNewPet):
			_petSlots[index] = {}
			_slotIndex = index
			newPet.personality = randi_range(0, Enums.Personality.values().size() - 1)
			if petData != null:
				newPet.petResource = petData
			else:
				newPet.petResource = _availableEggs[0]
			newPet.givenName = givenName
		else:
			_slotIndex = index
			newPet.setSavableData(loadPetDataFromSlot(_slotIndex))
	else:
		_petSlots.append({})
		if (index > _petSlots.size() - 1):
			_slotIndex = _petSlots.size() - 1
		else:
			_slotIndex = index
		newPet.personality = randi_range(0, Enums.Personality.values().size() - 1)
		if petData != null:
			newPet.petResource = petData
		else:
			newPet.petResource = _availableEggs[0]
		newPet.givenName = givenName
	
	if !_encounteredPets.has(newPet.petResource.name):
		_encounterNewPet(newPet.petResource)
	
	activePet = newPet
	activePet.loadResourceData()
	activePet.connect("UpdateStatusBars", _updateStatus)
	activePet.connect("UpdateStatRecord", _updateStatRecord)
	activePet.connect("ReadyToEvolve", evolvePet)
	activePet.boundries.append_array([leftBoundry.position, rightBoundry.position])
	activePet._evoStatsUpdated()
	call_deferred("add_child", activePet)
	GameEvents.NewPetSpawned.emit(activePet.petResource.stage == 0)
	GameEvents.PlayGameVFX.emit(VFXManager.VisualEffects.DUSTCLOUD, 
								activePet.position + Vector2(13, 0), 
								true, 
								2)
	GameEvents.PlayGameVFX.emit(VFXManager.VisualEffects.DUSTCLOUD, 
								activePet.position - Vector2(13, 0), 
								false, 
								2)
	
	SaveData.saveGameToFile()


func evolvePet(evolveTarget: PetTypeData):
	# Stop everything and start shaking the device
	await Settings.requestPlayerAttention()
	
	GameEvents.ResetAllTimers.emit()
	GameEvents.ShakeDeviceOnce.emit()
	GameEvents.ShakeDeviceOnce.emit()
	GameEvents.ClearObjects.emit()
	await get_tree().create_timer(1).timeout
	if activePet.petResource.stage != 0:
		activePet.sprite.play("Quirk")
	WaitingForStopGap.emit()
	await _PassStopGap
	
	activePet.evolvedFromIcons += [activePet.getSpriteIcon()]
	activePet.visible = false
	# Start Evolve Animation Sequence
	_evolvingPet.startSequence(activePet.position, 
								activePet.getSpriteIcon(), activePet.getSpriteOffset(), 
								evolveTarget.getSpriteIcon(), evolveTarget.getSpriteOffset(), 
								_evolveSequenceRate)
	await _evolvingPet.SequenceComplete
	activePet.visible = true

	# Set new resource and update visual information for it
	activePet.petResource = evolveTarget
	if !_encounteredPets.has(activePet.petResource.name):
		_encounterNewPet(activePet.petResource)
	activePet.loadResourceData()
	activePet.petState = Enums.PetState.ROAMING
	activePet._evoStatsUpdated()
	# Save the game
	SaveData.saveGameToFile()
	
	# Go about with the game
	GameEvents.StartNeedsTimers.emit()
	activePet.sprite.play("Quirk")
	await get_tree().create_timer(1).timeout
	GameEvents.NewPetEvolved.emit(false)
	GameEvents.PlayGameVFX.emit(VFXManager.VisualEffects.DUSTCLOUD, 
								activePet.position + Vector2(13, 0), 
								true, 
								2)
	GameEvents.PlayGameVFX.emit(VFXManager.VisualEffects.DUSTCLOUD, 
								activePet.position - Vector2(13, 0), 
								false, 
								2)
	if (activePet.petResource.stage > 0):
		AchievementManager.setAchievementFlag("EvolveAchiev1")
	if (activePet.petResource.stage > 1):
		AchievementManager.setAchievementFlag("EvolveAchiev2")
	if (activePet.petResource.stage > 2):
		AchievementManager.setAchievementFlag("EvolveAchiev3")
	 
	if (!AchievementManager.getAchievementFlag("EvolveAchiev4")):
		var isComplete
		for egg in _availableEggs:
			isComplete = true
			for pet in egg.getAllPossibleEvolutions():
				if !_encounteredPets.has(pet.name):
					isComplete = false
					break
			
			if (isComplete):
				break


func switchPet(index : int, previousPetDeleted := false):
	if ((index < 0 or index >= MAX_PET_SLOTS) and !previousPetDeleted):
		return
	
	if (!previousPetDeleted):
		await SaveData.saveGameToFile()
	
	GameEvents.ResetAllTimers.emit()
	if (activePet):
		activePet.queue_free()
	spawnPet(index)


func createNewPet(petData : PetTypeData, givenname : String):
	GameEvents.ResetAllTimers.emit()
	if (activePet):
		activePet.queue_free()
	spawnPet(_petSlots.size(), true, petData, givenname)


func killPet():
	GameEvents.ResetAllTimers.emit()
	GameEvents.ClearObjects.emit()
	var petData = activePet.getSavableData()
	activePet.queue_free()
	activePet = null
	deletePetSlot(_slotIndex, true)
	
	
	CallPetDeathScreen.emit(petData)

#endregion

#region Pet Save & Load Management
func gatherDataFromActivePet():
	if (activePet == null or _petSlots.size() <= 0):
		pass
	else:
		_petSlots[_slotIndex] = activePet.getSavableData().convertClassToDict()


func loadPetDataFromSlot(index : int) -> Pet.PetSaveData:
	var data : Pet.PetSaveData = Pet.PetSaveData.new()
	
	#TODO: Figure out a way of handling old save data that's missing things
	for propertyKey in _petSlots[index].keys():
		data.set(propertyKey, _petSlots[index][propertyKey])
	
	return data

func _encounterNewPet(petData : PetTypeData) -> void:
	#TODO: Probably track achievements or something
	_encounteredPets[petData.name] = petData

## Takes the stats from a pet and compares every element to the [param _statRecord] to see if it
## has been surpassed.
func _updateStatRecord(petData : PetTypeData, evoStats : Array, statusHistory : Array[Pet.StatusCondition]):
	for evolution : PetTypeData in petData.evolutions:
		if (!_statRecords.has(evolution)):
			_statRecords[evolution] = [0,0,0,0,0,0]
		if (!_statusRecords.has(evolution)):
			_statusRecords[evolution] = []
		for x in range(evoStats.size()):
			if (evoStats[x] > _statRecords[evolution][x]):
				_statRecords[evolution][x] = evoStats[x]
		for status in statusHistory:
			if (!_statusRecords[evolution].has(int(status))):
				_statusRecords[evolution].append(int(status))


## Gets the stat record for the given pet type. Returns a list of stats in the 
## following order:
## 0 = POW
## 1 = END
## 2 = SPD
## 3 = BAL
## 4 = Trauma
## 5 = Stat Total
func getStatRecord(petData : PetTypeData) -> Array:
	if (_statRecords.has(petData)):
		return _statRecords[petData]
	else:
		return [0,0,0,0,0,0]

func getStatusRecord(petData : PetTypeData) -> Array:
	if (_statusRecords.has(petData)):
		return _statusRecords[petData]
	else:
		return []

func _unlockNewEgg(eggData : PetTypeData) -> void:
	if (!_availableEggs.has(eggData)):
		#TODO: Achievement Tracking
		_encounterNewPet(eggData)
		_availableEggs.append(eggData)

## Returns a 2 item array with index 0 being an array of all eggs available and
## index 1 being a dictionary of every pet the player has encountered
func getPetProgressInformation() -> Array:
	return [_availableEggs, _encounteredPets]

#endregion

#region Utility Functions 

func getPetStage() -> int:
	return activePet.petResource.stage


func getSlotIndex() -> int:
	return _slotIndex


func getPetSlots() -> Array:
	return _petSlots


func checkPetDir() -> bool:
	return activePet.position.x >= lerp(leftBoundry.position.x, rightBoundry.position.x, .5)


func deletePetSlot(index : int, death := false) -> void:
	if (_petSlots.size() == 1 and !death):
		return
	_petSlots.remove_at(index)
	if (index == _slotIndex):
		_slotIndex = _petSlots.size() - 1
		if (!death):
			GameEvents.ChangePet.emit(_slotIndex, true)
	elif (index < _slotIndex):
		_slotIndex -= 1
	
	if (_petSlots.size() == 0 or _petSlots.size() == 1):
		_slotIndex = 0
	
	
	SaveData.saveGameToFile()




#endregion

#region Signal Functions

func _updateStatus(hungerValue, joyValue):
	hungerBar.updateBar(hungerValue, Pet.MAX_HUNGER)
	joyBar.updateBar(joyValue, Pet.MAX_JOY)
#endregion

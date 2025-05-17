extends Node2D

class_name PetManager

var implements = []

static var instance : PetManager = self

class DataSaver extends SaveData.DataSaver:
	func getCategoryName():
		return "PetManager"
	var _petSlots
	var _slotIndex
	
	func getDataToSave() -> Data:
		obj.gatherDataFromActivePet()
		return super()

const MAX_PET_SLOTS := 3

signal CallPetDeathScreen(petData : Dictionary)

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

# Called when the node enters the scene tree for the first time.
func _ready():
	GameEvents.PetDied.connect(killPet)
	GameEvents.ChangePet.connect(switchPet)
	PetManager.instance = self
	_boundryDistance = Vector2(rightBoundry.position.x - leftBoundry.position.x, 
								rightBoundry.position.y - leftBoundry.position.y)

# Used to convert percentage positions to local positions
func percentToPosn(percentPosn : Vector2) -> Vector2:
	return Vector2(lerpf(leftBoundry.position.x, rightBoundry.position.x, percentPosn.x), 
			lerpf(leftBoundry.position.y, rightBoundry.position.y, percentPosn.y))

# converts a local position to a percentage position
func posnToPercent(posn : Vector2) -> Vector2:
	var posnDistance = Vector2(posn.x - leftBoundry.position.x, posn.y - leftBoundry.position.y)
	return Vector2(posnDistance.x / _boundryDistance.x, posnDistance.y / _boundryDistance.y)

# take a position and increment it by the percent given
func addPercentToPosn(posn : Vector2, percentPosn : Vector2) -> Vector2:
	return percentToPosn(posnToPercent(posn) + percentPosn)

#region Pet Spawning & Evolving
func spawnPet(index := -1, isNewPet := false):
	if (index >= MAX_PET_SLOTS):
		return
	
	var newPet = respawnPet.instantiate()
	newPet.position = petSpawnPoint.position
	
	# Load pet data from slots if applicable, otherwise use current slot, all else
	# fails it will create a brand new one
	if (_petSlots.size() <= 0):
		_petSlots.append({})
		_slotIndex = 0
		newPet.personality = randi_range(0, Enums.Personality.values().size() - 1)
		newPet.petResource = petStartResource
	elif (index < 0 and not isNewPet):
		newPet.setSavableData(loadPetDataFromSlot(_slotIndex))
	elif (index < _petSlots.size() and index >= 0):
		if (isNewPet):
			_petSlots[index] = {}
			_slotIndex = index
			newPet.personality = randi_range(0, Enums.Personality.values().size() - 1)
			newPet.petResource = petStartResource
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
		newPet.petResource = petStartResource
	
	#if (index >= 0 and index < _petSlots.size()):
		#_slotIndex = index
		#newPet.setSavableData(loadPetDataFromSlot(_slotIndex))
	#elif (!isNewPet):
		#newPet.setSavableData(loadPetDataFromSlot(_slotIndex))
	#else:
		#print("Could not find loaded pet at slot index ", index, ", creating new pet and saving to slot 0")
		#_petSlots.append({})
		#_slotIndex = 0
		#newPet.personality = randi_range(0, Enums.Personality.values().size() - 1)
		#newPet.petResource = petStartResource
	
	activePet = newPet
	activePet.loadResourceData()
	activePet.connect("UpdateStatusBars", _updateStatus)
	activePet.connect("ReadyToEvolve", evolvePet)
	activePet.boundries.append_array([leftBoundry.position, rightBoundry.position])
	
	
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
	GameEvents.ResetAllTimers.emit()
	GameEvents.ShakeDeviceOnce.emit()
	GameEvents.ShakeDeviceOnce.emit()
	await get_tree().create_timer(1).timeout
	GameEvents.ClearObjects.emit()
	
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
	activePet.loadResourceData()
	activePet.petState = Enums.PetState.ROAMING
	
	# Save the game
	SaveData.saveGameToFile()
	
	# Go about with the game
	GameEvents.StartNeedsTimers.emit()
	GameEvents.NewPetEvolved.emit(false)
	GameEvents.PlayGameVFX.emit(VFXManager.VisualEffects.DUSTCLOUD, 
								activePet.position + Vector2(39, 0), true, 1.3)
	GameEvents.PlayGameVFX.emit(VFXManager.VisualEffects.DUSTCLOUD, 
								activePet.position - Vector2(39, 0), false, 1.3)


func switchPet(index : int, previousPetDeleted := false):
	if ((index < 0 or index >= MAX_PET_SLOTS) and !previousPetDeleted):
		return
	
	if (!previousPetDeleted):
		await SaveData.saveGameToFile()
	
	GameEvents.ResetAllTimers.emit()
	if (activePet):
		activePet.queue_free()
	spawnPet(index)


func killPet():
	GameEvents.ResetAllTimers.emit()
	GameEvents.PauseGame.emit()
	var petData = activePet.getSavableData()
	activePet.queue_free()
	activePet = null
	deletePetSlot(_slotIndex, true)
	
	CallPetDeathScreen.emit(petData)

#endregion

#region Pet Save & Load Management
func gatherDataFromActivePet():
	#TODO: Handle Saving data when no pet is spawned
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

#endregion

#region Utility Functions 

func getPetStage() -> int:
	return activePet.petResource.stage


func getSlotIndex() -> int:
	return _slotIndex


func getPetSlots() -> Array:
	return _petSlots


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

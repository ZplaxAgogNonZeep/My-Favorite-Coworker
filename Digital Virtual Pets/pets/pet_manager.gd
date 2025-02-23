extends Node2D

var implements = []

class DataSaver extends SaveData.DataSaver:
	func getCategoryName():
		return "PetManager"
	var _petSlots
	var _slotIndex
	
	func getDataToSave() -> Data:
		obj.gatherDataFromActivePet()
		return super()

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
var _petSlots = [{}]
var _slotIndex : int

# Called when the node enters the scene tree for the first time.
func _ready():
	GameEvents.SpawnPetOnStart.connect(spawnPetOnStart)
	GameEvents.PetDied.connect(killPet)


#region Pet Spawning & Evolving
# TODO: Update Spawn Pet to be from game manager
func spawnPetOnStart():
	pass


func spawnPet(index : int = -1):
	var newPet = respawnPet.instantiate()
	newPet.position = petSpawnPoint.position
	
	# Load pet data from slots if applicable, otherwise use default / randomized
	if (index >= 0 and index < _petSlots.size()):
		newPet.setSavableData(loadPetDataFromSlot(index))
	else:
		newPet.personality = randi_range(0, Enums.Personality.values().size() - 1)
		newPet.petResource = petStartResource
	
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
	
	# Save the game
	SaveData.saveGameToFile()
	
	# Go about with the game
	GameEvents.StartNeedsTimers.emit()
	GameEvents.NewPetEvolved.emit(false)
	GameEvents.PlayGameVFX.emit(VFXManager.VisualEffects.DUSTCLOUD, 
								activePet.position + Vector2(39, 0), true, 1.3)
	GameEvents.PlayGameVFX.emit(VFXManager.VisualEffects.DUSTCLOUD, 
								activePet.position - Vector2(39, 0), false, 1.3)

#TODO: Update to be a whole death sequence
func killPet():
	print("Pet has Died!")
	GameEvents.ResetAllTimers.emit()
	activePet.queue_free()
	spawnPet()

#endregion

#region Pet Save & Load Management
func gatherDataFromActivePet():
	_petSlots[_slotIndex] = activePet.getSavableData().convertClassToDict()


func loadPetDataFromSlot(index : int) -> Pet.PetSaveData:
	var data : Pet.PetSaveData = Pet.PetSaveData.new()
	
	for propertyKey in _petSlots[index].keys():
		data.set(propertyKey, _petSlots[index][propertyKey])
	
	return data

#endregion

#region Utility Functions 

func getPetStage() -> int:
	return activePet.petResource.stage

#endregion

#region Signal Functions

func _updateStatus(hungerValue, joyValue):
	hungerBar.updateBar(hungerValue, Pet.MAX_HUNGER)
	joyBar.updateBar(joyValue, Pet.MAX_JOY)
#endregion

extends Node2D

var implements = []
@export_category("Object References")
@export var hungerBar : StatusBar
@export var joyBar : StatusBar
@export var leftBoundry : Marker2D
@export var rightBoundry : Marker2D
@export var animationManager : AnimationPlayer
@export_category("Pet References")
@export var respawnPet : PackedScene
@export var activePet : Pet
@export var petSpawnPoint : Marker2D
@export_category("Pet Evolution Variables")
@export var _evolvingPet : EvolvingPet
@export var _evolveSequenceRate : float

var stage = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	GameEvents.SpawnPetOnStart.connect(spawnPetOnStart)
	GameEvents.PetDied.connect(killPet)


func spawnPetOnStart():
	if (not activePet):
		spawnNewPet()

func spawnNewPet():
	var newPet = respawnPet.instantiate()
	newPet.position = petSpawnPoint.position
	
	newPet.personality = randi_range(0, Enums.Personality.values().size() - 1)
	
	activePet = newPet
	activePet.connect("UpdateStatusBars", _updateStatus)
	activePet.connect("ReadyToEvolve", evolvePet)
	activePet.boundries.append_array([leftBoundry.position, rightBoundry.position])
	
	call_deferred("add_child", activePet)
	GameEvents.NewPetSpawned.emit(true)
	GameEvents.PlayGameVFX.emit(VFXManager.VisualEffects.DUSTCLOUD, activePet.position + Vector2(13, 0), true, 2)
	GameEvents.PlayGameVFX.emit(VFXManager.VisualEffects.DUSTCLOUD, activePet.position - Vector2(13, 0), false, 2)
	
	


func evolvePet(evolveTarget: PackedScene):
	stage += 1
	GameEvents.ResetAllTimers.emit()
	GameEvents.ShakeDeviceOnce.emit()
	GameEvents.ShakeDeviceOnce.emit()
	await get_tree().create_timer(1).timeout
	GameEvents.ClearObjects.emit()
	var transferVar = [activePet.hungerValue, 
						activePet.joyValue, 
						activePet.traumaCount, 
						activePet.personality,
						activePet.abilityStats,
						activePet.evolvedFromIcons + [activePet.getSpriteIcon()],
						activePet.boundries]
	
	# Probably need to find a way to transfer unique variables here
	
	activePet.queue_free()
	var evolvedPet = evolveTarget.instantiate()
	
	evolvedPet.position = petSpawnPoint.position
	evolvedPet.hungerValue = transferVar[0]
	evolvedPet.joyValue = transferVar[1]
	evolvedPet.traumaCount = transferVar[2]
	evolvedPet.personality = transferVar[3]
	evolvedPet.abilityStats = transferVar[4]
	print(transferVar[5])
	evolvedPet.evolvedFromIcons = transferVar[5]
	evolvedPet.boundries = transferVar[6]
	
	activePet.visible = false
	
	## Start Evolve Animation Sequence
	_evolvingPet.startSequence(activePet.position, activePet.getSpriteIcon(), activePet.getSpriteOffset(), 
								evolvedPet.getSpriteIcon(), evolvedPet.getSpriteOffset(), _evolveSequenceRate)
	
	await _evolvingPet.SequenceComplete
	
	activePet = evolvedPet
	activePet.connect("UpdateStatusBars", _updateStatus)
	activePet.connect("ReadyToEvolve", evolvePet)
	await call_deferred("add_child", activePet)
	
	GameEvents.StartNeedsTimers.emit()
	GameEvents.NewPetEvolved.emit(false)
	GameEvents.PlayGameVFX.emit(VFXManager.VisualEffects.DUSTCLOUD, 
								activePet.position + Vector2(39, 0), true, 1.3)
	GameEvents.PlayGameVFX.emit(VFXManager.VisualEffects.DUSTCLOUD, 
								activePet.position - Vector2(39, 0), false, 1.3)


func killPet():
	print("Pet has Died!")
	GameEvents.ResetAllTimers.emit()
	activePet.queue_free()
	spawnNewPet()


func _updateStatus(hungerValue, joyValue):
	hungerBar.updateBar(hungerValue, Pet.MAX_HUNGER)
	joyBar.updateBar(joyValue, Pet.MAX_JOY)

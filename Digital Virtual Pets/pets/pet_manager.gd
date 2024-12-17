extends Node2D

var implements = []
@export_category("Object References")
@export var hungerBar : StatusBar
@export var joyBar : StatusBar
@export var leftBoundry : Marker2D
@export var rightBoundry : Marker2D
@export_category("Pet References")
@export var respawnPet : PackedScene
@export var activePet : Pet
@export var petSpawnPoint : Marker2D

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
	GameEvents.NewPetSpawned.emit()
	


func evolvePet(evolveTarget: PackedScene):
	GameEvents.ResetAllTimers.emit()
	GameEvents.ShakeDeviceOnce.emit()
	GameEvents.ShakeDeviceOnce.emit()
	await get_tree().create_timer(2).timeout
	GameEvents.ClearObjects.emit()
	var transferVar = [activePet.hungerValue, 
						activePet.joyValue, 
						activePet.traumaCount, 
						activePet.personality,
						activePet.abilityStats,
						activePet.evolvedFromIcons + [activePet.iconSprite],
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
	
	activePet = evolvedPet
	activePet.connect("UpdateStatusBars", _updateStatus)
	activePet.connect("ReadyToEvolve", evolvePet)
	call_deferred("add_child", activePet)
	GameEvents.NewPetSpawned

func killPet():
	print("Pet has Died!")
	GameEvents.ResetAllTimers.emit()
	activePet.queue_free()
	spawnNewPet()

func _updateStatus(hungerValue, joyValue):
	hungerBar.updateBar(hungerValue, Pet.MAX_HUNGER)
	joyBar.updateBar(joyValue, Pet.MAX_JOY)

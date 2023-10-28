extends Node2D

var implements = []
@export_category("Object References")
@export var hungerBar : Node2D
@export var joyBar : Node2D
@export var leftBoundry : Marker2D
@export var rightBoundry : Marker2D
@export_category("Pet References")
@export var respawnPet : PackedScene
@export var activePet : Node2D
@export var petSpawnPoint : Marker2D

# Called when the node enters the scene tree for the first time.
func _ready():
	if not activePet:
		await get_tree().create_timer(1).timeout
		# RACE CONDITION
		spawnNewPet()
	


func spawnNewPet():
	var newPet = respawnPet.instantiate()
	newPet.position = petSpawnPoint.position
	
	newPet.personality = randi_range(0, Enums.Personality.values().size() - 1)
	
	activePet = newPet
	call_deferred("add_child", activePet)
	print("Game SHOULD emit pet spawned")
	GameEvents.NewPetSpawned.emit()
	

func evolvePet():
	pass

func killPet():
	print("Pet has Died!")
	GameEvents.ResetAllTimers.emit()
	activePet.queue_free()
	spawnNewPet()

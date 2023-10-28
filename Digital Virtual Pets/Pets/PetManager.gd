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
		spawnPet()
	


func spawnPet():
	var newPet = respawnPet.instantiate()
	newPet.position = petSpawnPoint.position
	activePet = newPet
	add_child(newPet)

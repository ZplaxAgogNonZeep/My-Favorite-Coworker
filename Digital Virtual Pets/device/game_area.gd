extends Node2D

const TIMER_TIME := 5

@export_category("Object References")
@export var device : Node2D
#@export var activePet : Node2D
@export var objectContainer : Node2D
@export var petManager : Node2D
@export var menuManager : Node2D
@export var timers : Node
@export var boundries : Array[Marker2D] # 0 = Left | 1 = Right
@export var ObjectSpawnLocations : Array[Marker2D]
@export_category("Spawnable Objects")
@export var foodInstance : PackedScene

var evolveInterval = 15

func _ready():
	GameEvents.NewPetSpawned.connect(petSpawned)
	GameEvents.FeedPet.connect(feed)
	GameEvents.ClearObjects.connect(clearAllObjects)
	
	GameEvents.SpawnPetOnStart.emit()

func _unhandled_input(event):
	if Input.is_action_just_pressed("Debug"):
		#GameEvents.HopDeviceOnce.emit()
		#GameEvents.HopDeviceOnce.emit()
		GameEvents.ShakeDeviceOnce.emit()
		#GameEvents.HopDeviceOnce.emit()
		#GameEvents.StartShakeDevice.emit()

#region Events 

func feed():
	var food = foodInstance.instantiate()
	food.stopFallingAt = boundries[0].position.y
	randomize()
	food.position = ObjectSpawnLocations[randi_range(0, 3)].position
	objectContainer.add_child(food)

func petSpawned():
	randomize()
	$GameTimers/HungerTimer.start((randf_range(3, 15)) * device.chatSpeed)
	randomize()
	$GameTimers/JoyTimer.start((randf_range(3, 15)) * device.chatSpeed)
	$GameTimers/EvolveTimer.start(evolveInterval)

func clearAllObjects():
	for x in range(objectContainer.get_child_count()):
		objectContainer.get_child(x).queue_free()

#endregion

#region Timer Controls 

func tickHunger():
	GameEvents.TickHunger.emit()
	randomize()
	$GameTimers/HungerTimer.start((randf_range(3, 15)) * device.chatSpeed)


func tickJoy():
	GameEvents.TickJoy.emit()
	randomize()
	$GameTimers/JoyTimer.start((randf_range(3, 15)) * device.chatSpeed)


func evolveCheck():
	GameEvents.EvolveCheck.emit()
	$GameTimers/EvolveTimer.start(evolveInterval)

#endregion




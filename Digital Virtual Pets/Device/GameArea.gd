extends Node2D

const TIMER_TIME := 5

@export_category("Object References")
@export var device : Node2D
#@export var activePet : Node2D
@export var petManager : Node2D
@export var menuManager : Node2D
@export var timers : Node
@export var boundries : Array[Marker2D] # 0 = Left | 1 = Right
@export var ObjectSpawnLocations : Marker2D
@export_category("User Interface References")
@export var joyBar : Node2D
@export var hungerBar : Node2D
@export_category("Spawnable Objects")
@export var foodInstance : PackedScene

func _ready():
	$GameTimers/HungerTimer.start((randf_range(3, 15)) * device.chatSpeed)
	$GameTimers/JoyTimer.start((randf_range(3, 15)) * device.chatSpeed)
	GameEvents.FeedPet.connect(feed)
	
	

# Events ===========================================================================================

func feed():
	var food = foodInstance.instantiate()
	food.stopFallingAt = boundries[0].position.y
	food.position = ObjectSpawnLocations.position
	add_child(food)

# Timer Controls ===================================================================================

func tickHunger():
	GameEvents.TickHunger.emit()
	$GameTimers/HungerTimer.start((randf_range(3, 15)) * device.chatSpeed)


func tickJoy():
	GameEvents.TickJoy.emit()
	$GameTimers/JoyTimer.start((randf_range(3, 15)) * device.chatSpeed)







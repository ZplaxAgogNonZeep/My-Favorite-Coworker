extends Node2D

const TIMER_TIME := 5

@export_category("Object References")
@export var device : Node2D
@export var activePet : Node2D
@export var background : Node2D
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

func _unhandled_input(event):
	if Input.is_action_just_released("Debug"):
		activePet.hungerValue = 100
		hungerBar.updateBar(activePet.hungerValue, activePet.MAX_HUNGER)
		activePet.joyValue = 100
		joyBar.updateBar(activePet.joyValue, activePet.MAX_JOY)

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







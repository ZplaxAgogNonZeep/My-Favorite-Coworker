extends Node2D

const TIMER_TIME := 5

@export_category("Object References")
@export var device : Node2D
@export var activePet : Node2D
@export var background : Node2D
@export var timers : Node

@export_category("User Interface References")
@export var joyBar : Node2D
@export var hungerBar : Node2D

func _ready():
	tickHunger()
	tickJoy()

func _unhandled_input(event):
	if Input.is_action_just_released("Debug"):
		activePet.hungerValue = 100
		hungerBar.updateBar(activePet.hungerValue, activePet.MAX_HUNGER)
		activePet.joyValue = 100
		joyBar.updateBar(activePet.joyValue, activePet.MAX_JOY)


func tickHunger():
	GameEvents.TickHunger.emit()
	$GameTimers/HungerTimer.start((randf_range(3, 15)) * device.chatSpeed)


func tickJoy():
	GameEvents.TickJoy.emit()
	$GameTimers/JoyTimer.start((randf_range(3, 15)) * device.chatSpeed)







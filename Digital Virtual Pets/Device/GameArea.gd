extends Node2D

const TIMER_TIME := 5

@export_category("Object References")
@export var device : Node2D
@export var activePet : Node2D
@export var background : Node2D

@export_category("User Interface References")
@export var JoyBar : ProgressBar
@export var HungerBar : ProgressBar

func tickHunger():
	print("Ticking Hunger")
	randomize()
	activePet.hungerValue -= randi_range(1, 5)
	#testBar1.value = activePet.hungerValue
	$HungerTimer.start((randf_range(3, 15)) * device.chatSpeed)


func tickJoy():
	print("ticking Joy")
	randomize()
	activePet.joyValue -= randi_range(0, 5)
	#testBar2.value = activePet.joyValue
	$JoyTimer.start((randf_range(3, 15)) * device.chatSpeed)


func _unhandled_input(event):
	if Input.is_action_just_released("Debug"):
		activePet.hungerValue = 100
		#testBar1.value = activePet.hungerValue
		activePet.joyValue = 100
		#testBar2.value = activePet.joyValue


func _ready():
	tickHunger()
	tickJoy()



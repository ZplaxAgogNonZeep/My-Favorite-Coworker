extends Node2D
@export
var device : Node2D

@export 
var activePet : Node2D
@export 
var background : Node2D



const TIMER_TIME := 5



@export
var testBar1 : ProgressBar
@export
var testBar2 : ProgressBar


func tickHunger():
	print("Ticking Hunger")
	randomize()
	activePet.hungerValue -= randi_range(1, 5)
	testBar1.value = activePet.hungerValue
	$HungerTimer.start((randf_range(3, 15)) * device.chatSpeed)

func tickJoy():
	print("ticking Joy")
	randomize()
	activePet.joyValue -= randi_range(0, 5)
	testBar2.value = activePet.joyValue
	$JoyTimer.start((randf_range(3, 15)) * device.chatSpeed)

func _unhandled_input(event):
	if Input.is_action_just_released("Debug"):
		activePet.hungerValue = 100
		testBar1.value = activePet.hungerValue
		activePet.joyValue = 100
		testBar2.value = activePet.joyValue

# Called when the node enters the scene tree for the first time.
func _ready():
	tickHunger()
	tickJoy()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

extends Minigame

var implements = [Interface.MiniGame]


@export_category("Game Values")
@export var _gameDuration : float
#@export var mashGoal : int
#@export var mashGoalMax : int
@export var _mashMax : int
@export var _mashGoalSizes : Array[int]
@export var _meterSizes : Array[int]
@export var decreaseFrequency : float
@export var decreaseAmount : int
@export var mashMeter : MashMeter

var mashAmount : int = 0
var gameIteration : int = 3
var mashMode := false
var _dir := 1

func _process(delta):
	if gameRunning and mashMode and $MashDecrease.is_stopped():
		if (mashMeter.isValueMaxed()):
			_dir = -1
		if (mashMeter.isValueZero()):
			_dir = 1
		mashMeter.addToValue(decreaseAmount * _dir)
		$MashDecrease.start(decreaseFrequency)


func startGame(pet : Node2D, playMenu : Node2D):
	super(pet, playMenu)
	
	randomize()
	var goal = randi_range(_meterSizes[_difficulty], _mashMax - floori(_mashGoalSizes[_difficulty] * 1.5))
	mashMeter.initializeMeter(_mashMax, goal, goal + _mashGoalSizes[_difficulty], _meterSizes[_difficulty])
	
	$PseudoPet.sprite.play("Quirk")
	updateGameText("3")
	$Timer.start(.5)
	gameRunning = true


func onWin():
	updateGameText("NOW!")
	$PseudoPet.hop()
	$Hammer.set_animation("Down")
	await get_tree().create_timer(1).timeout
	$Hammer.set_animation("Up")
	super()


func updateMashBar(value : int, maxAmount : int):
	mashMeter.setValue(value)


func takeInput(input : Enums.DeviceButton):
	if gameRunning and mashMode:
			match input:
				Enums.DeviceButton.CENTER_BUTTON:
					gameRunning = false
					mashMode = false
					if (mashMeter.isWithinGoal()):
						onWin()
					else:
						onLose()


func _on_timer_timeout():
	if gameIteration > 0:
		gameIteration -= 1
		updateGameText(str(gameIteration))
		$Timer.start(.5)
	elif gameIteration == 0:
		gameIteration -= 1
		updateGameText("PREPARE!")
		$PseudoPet.sprite.play("Idle")
		$Timer.start(_gameDuration)
		mashMode = true
	else:
		if (gameRunning):
			gameRunning = false
			onLose()
		#if mashAmount >= mashGoal:
			#onWin()
		#else:
			#onLose()

func tickMashDecrease():
	if gameRunning and mashMode:
		if (mashMeter.isValueMaxed()):
			_dir = -1
		if (mashMeter.isValueZero()):
			_dir = 1
		mashMeter.addToValue(decreaseAmount * _dir)

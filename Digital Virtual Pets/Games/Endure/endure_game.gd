extends Minigame

var implements = [Interface.MiniGame]

@export_category("Game Values")
@export var incrementFrequency : float
@export var gameDuration : int
@export var _mashMax : int
@export var _goalSizes : Array[int]
@export var decreaseFrequency : float
@export var decreaseAmount : int

var mashMode := false
var mashAmount : int= 0
var increment := 3

func _process(delta):
	if gameRunning and mashMode and $MashDecrease.is_stopped():
		$MashDecrease.start(decreaseFrequency)

func startGame(pet : Node2D, playMenu : Node2D):
	super(pet, playMenu)
	
	randomize()
	var goal = randi_range(5, _mashMax - (_goalSizes[_difficulty] * 2))
	$MashMeter.initializeMeter(_mashMax, goal, goal + _goalSizes[_difficulty], 5)
	
	$PseudoPet.sprite.play("Quirk")
	updateGameText("GET READY")
	$Timer.start(incrementFrequency)
	gameRunning = true


func takeInput(input : Enums.DeviceButton):
	if gameRunning and mashMode:
			match input:
				Enums.DeviceButton.CENTER_BUTTON:
					$MashMeter.addToValue(2)
					$PseudoPet.hop()
					#updateMashBar(mashAmount, mashMax)


func incrementGame():
	if increment > 0:
		updateGameText(str(increment))
		increment -= 1
		$Timer.start(incrementFrequency)
	elif increment == 0:
		
		updateGameText("ENDURE!!")
		$Steam.play()
		$PseudoPet.sprite.play("Idle")
		increment -= 1
		mashMode = true
		$Timer.start(gameDuration)
	else:
		mashMode = false
		if $MashMeter.isWithinGoal():
			onWin()
		else:
			onLose()

func decreaseMash():
	if gameRunning and mashMode:
		$MashMeter.addToValue(-1)

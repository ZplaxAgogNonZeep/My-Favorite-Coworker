extends Minigame

var implements = [Interface.MiniGame]


@export var intervalTime : float
@export var _minigameTheme : MusicTrack

var intervalCount := 6

var correctDirIsRight : bool
var guessDirIsRight : bool
var isGuessMade := false


func startGame(pet : Node2D, playMenu : Node2D):
	super(pet, playMenu)
	$PseudoPet.sprite.play("Idle")
	randomize()
	if randi_range(0, 1):
		correctDirIsRight = false
	else:
		correctDirIsRight = true
	print(correctDirIsRight)
	updateGameText("GUESS")
	intervalCount -= 1
	get_tree().create_timer(intervalTime).connect("timeout", intervalMet)
	gameRunning = true


func takeInput(input : Enums.DeviceButton):
		if gameRunning:
			match input:
				Enums.DeviceButton.LEFT_BUTTON:
					guessDirIsRight = false
					isGuessMade = true
				Enums.DeviceButton.RIGHT_BUTTON:
					guessDirIsRight = true
					isGuessMade = true


func intervalMet():
	if intervalCount == 5:
		updateGameText("LEFT")
		$PseudoPet.indicateDirection(false)
	elif intervalCount == 4:
		updateGameText("Right")
		$PseudoPet.indicateDirection(true)
	elif intervalCount > 0:
		$PseudoPet.stopIndicatingDirection()
		updateGameText(str(intervalCount))
	
	if intervalCount < 0:
		gameRunning = false
		$PseudoPet.setDirection(correctDirIsRight)
		if (guessDirIsRight == correctDirIsRight):
			updateGameText("WIN!")
			$PseudoPet.sprite.play("Quirk")
			$PseudoPet.hop(2)
			onWin()
		else:
			updateGameText("LOSE!")
			$PseudoPet.sprite.play("Quirk")
			onLose()
	else:
		get_tree().create_timer(intervalTime).connect("timeout", intervalMet)
		intervalCount -= 1

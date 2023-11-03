extends Control

var implements = [Interface.MiniGame]

@export var status : Label
@export var intervalTime : float
@export var joyIncrement : int
@export var statIncrement : int

var playMenu : Panel
var connectedPet : Node2D
var gameRunning := false
var intervalCount := 6

var correctDirIsRight : bool
var guessDirIsRight : bool
var isGuessMade := false


func startGame(pet : Node2D, playMenu : Panel):
	connectedPet = pet
	self.playMenu = playMenu
	$PseudoPet.sprite.set_sprite_frames(pet.sprite.sprite_frames)
	$PseudoPet.sprite.animation = "Idle"
	
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
	
	if intervalCount == 0:
		gameRunning = false
		$PseudoPet.setDirection(correctDirIsRight)
		if (guessDirIsRight == correctDirIsRight):
			updateGameText("WIN!")
			$PseudoPet.hop(2)
			onWin()
		else:
			updateGameText("LOSE!")
			onLose()
	else:
		get_tree().create_timer(intervalTime).connect("timeout", intervalMet)
		intervalCount -= 1

func updateGameText(text : String):
	status.text = text

func onWin():
	print("You Won!")
	randomize()
	var statToIncrease = randi_range(0,3)
	connectedPet.receivePlay(joyIncrement, statToIncrease, statIncrement)
	await get_tree().create_timer(1).timeout
	endGame()

func onLose():
	print("You Lose!")
	await get_tree().create_timer(1).timeout
	endGame()

func endGame():
	playMenu.closeMenu()
	queue_free()

func takeInput(input : Enums.InputType):
		if gameRunning:
			match input:
				Enums.InputType.LEFTBUTTON:
					guessDirIsRight = false
					isGuessMade = true
				Enums.InputType.RIGHTBUTTON:
					guessDirIsRight = true
					isGuessMade = true

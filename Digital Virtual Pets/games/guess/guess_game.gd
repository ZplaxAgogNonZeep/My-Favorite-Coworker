extends Node2D

var implements = [Interface.MiniGame]

@export var status : Label
@export var intervalTime : float
@export var joyIncrement : int
@export var statIncrement : int
@export var _minigameTheme : MusicTrack

var playMenu : Node2D
var connectedPet : Node2D
var gameRunning := false
var intervalCount := 6

var correctDirIsRight : bool
var guessDirIsRight : bool
var isGuessMade := false


func startGame(pet : Node2D, playMenu : Node2D):
	SfxManager.playMusic(_minigameTheme)
	connectedPet = pet
	self.playMenu = playMenu
	$PseudoPet.sprite.set_sprite_frames(pet.sprite.sprite_frames)
	$PseudoPet.sprite.offset = pet.sprite.offset
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

func updateGameText(text : String):
	status.text = text

func onWin():
	SfxManager.incrementMusic(1)
	print("You Won!")
	randomize()
	var statToIncrease = randi_range(0,3)
	connectedPet.receivePlay(joyIncrement, statToIncrease, statIncrement)
	await get_tree().create_timer(1).timeout
	endGame()

func onLose():
	SfxManager.incrementMusic(0)
	print("You Lose!")
	await get_tree().create_timer(1).timeout
	endGame()

func endGame():
	playMenu.closeMenu()
	queue_free()

func takeInput(input : Enums.DeviceButton):
		if gameRunning:
			match input:
				Enums.DeviceButton.LEFT_BUTTON:
					guessDirIsRight = false
					isGuessMade = true
				Enums.DeviceButton.RIGHT_BUTTON:
					guessDirIsRight = true
					isGuessMade = true

extends Control

var implements = [Interface.MiniGame]

@export var joyIncrement : int
@export var statIncrement : int
@export var statToIncrease : Enums.AbilityStat

var playMenu : Panel
var connectedPet : Node2D
var gameRunning : bool

func startGame(pet : Node2D, playMenu : Panel):
	connectedPet = pet
	self.playMenu = playMenu
	$PseudoPet.sprite.set_sprite_frames(pet.sprite.sprite_frames)
	$PseudoPet.sprite.animation = "Idle"
	
	updateGameText("WAIT")

	gameRunning = true

func onWin():
	print("You Lose!")
	connectedPet.receivePlay(joyIncrement, statToIncrease, statIncrement)
	await get_tree().create_timer(1).timeout
	endGame()

func onLose():
	print("You Lose!")
	await get_tree().create_timer(1).timeout
	endGame()

func endGame():
	pass

func updateGameText(text : String):
	$Status.text = text

func takeInput(input : Enums.InputType):
	if gameRunning:
		pass

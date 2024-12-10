extends Control

var implements = [Interface.MiniGame]

@export_category("Stat Values")
@export var joyIncrement : int
@export var statIncrement : int
@export var statToIncrease : Enums.AbilityStat
@export_category("Game Values")
@export var incrementFrequency : float
@export var gameDuration : int
@export var mashMax : int
@export var mashGoalMin : int
@export var mashGoalMax : int
@export var decreaseFrequency : float
@export var decreaseAmount : int

var playMenu : Panel
var connectedPet : Node2D
var gameRunning := false
var mashMode := false
var mashAmount : int= 0
var increment := 3

func _process(delta):
	if gameRunning and mashMode and mashAmount > 0 and $MashDecrease.is_stopped():
		$MashDecrease.start(decreaseFrequency)

func startGame(pet : Node2D, playMenu : Panel):
	connectedPet = pet
	self.playMenu = playMenu
	$PseudoPet.sprite.set_sprite_frames(pet.sprite.sprite_frames)
	$PseudoPet.sprite.offset = pet.sprite.offset
	$PseudoPet.sprite.play("Quirk")
	$MashMeter.initializeMeter(mashMax, mashGoalMin, mashGoalMax)
	updateGameText("GET READY")
	$Timer.start(incrementFrequency)
	gameRunning = true

func endGame():
	playMenu.closeMenu()
	queue_free()

func updateGameText(text : String):
	$Status.text = text

func updateMashBar(value : int, maxAmount : int):
	$MashMeter.updateMeter(value, maxAmount)

func takeInput(input : Enums.InputType):
	if gameRunning and mashMode:
			match input:
				Enums.InputType.MIDDLEBUTTON:
					mashAmount += 1
					updateMashBar(mashAmount, mashMax)
#					$PseudoPet.hop()

func onWin():
	gameRunning = false
	updateGameText("WIN!")
	$PseudoPet.sprite.play("Quirk")
	$PseudoPet.hop(2)
	connectedPet.receivePlay(joyIncrement, statToIncrease, statIncrement)
	await get_tree().create_timer(2).timeout
	endGame()

func onLose():
	gameRunning = false
	updateGameText("LOSE!")
	$PseudoPet.sprite.play("Quirk")
	await get_tree().create_timer(2).timeout
	endGame()


func incrementGame():
	if increment > 0:
		updateGameText(str(increment))
		increment -= 1
		$Timer.start(incrementFrequency)
	elif increment == 0:
		updateGameText("ENDURE!!")
		$PseudoPet.sprite.play("Idle")
		increment -= 1
		mashMode = true
		$Timer.start(gameDuration)
	else:
		mashMode = false
		if mashAmount >= mashGoalMin and mashAmount <= mashGoalMax:
			onWin()
		else:
			onLose()

func decreaseMash():
	if gameRunning and mashMode:
		if mashAmount > 0:
			mashAmount -= decreaseAmount
		if mashAmount < 0:
			mashAmount = 0
		updateMashBar(mashAmount, mashMax)

extends Node2D

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

var playMenu : Node2D
var connectedPet : Node2D
var gameRunning := false
var mashMode := false
var mashAmount : int= 0
var increment := 3

func _process(delta):
	if gameRunning and mashMode and $MashDecrease.is_stopped():
		$MashDecrease.start(decreaseFrequency)

func startGame(pet : Node2D, playMenu : Node2D):
	connectedPet = pet
	self.playMenu = playMenu
	$PseudoPet.sprite.set_sprite_frames(pet.sprite.sprite_frames)
	$PseudoPet.sprite.offset = pet.sprite.offset
	$PseudoPet.sprite.play("Quirk")
	$MashMeter.initializeMeter(mashMax, mashGoalMin, mashGoalMax, 5)
	updateGameText("GET READY")
	$Timer.start(incrementFrequency)
	gameRunning = true

func endGame():
	playMenu.closeMenu()
	queue_free()

func updateGameText(text : String):
	$Status.text = text

func takeInput(input : Enums.DeviceButton):
	if gameRunning and mashMode:
			match input:
				Enums.DeviceButton.CENTER_BUTTON:
					$MashMeter.addToValue(1)
					$PseudoPet.hop()
					#updateMashBar(mashAmount, mashMax)

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

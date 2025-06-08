extends Node2D

var implements = [Interface.MiniGame]

@export_category("Stat Values")
@export var joyIncrement : int
@export var statIncrement : int
@export var statToIncrease : Enums.AbilityStat
@export_category("Game Values")
@export var gameDuration : float
@export var mashGoal : int
@export var mashGoalMax : int
@export var mashMax : int
@export var decreaseFrequency : float
@export var decreaseAmount : int
@export var mashMeter : Node2D
@export var _minigameTheme : MusicTrack

var playMenu : Node2D
var connectedPet : Node2D
var gameRunning : bool
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
	SfxManager.playMusic(_minigameTheme)
	connectedPet = pet
	self.playMenu = playMenu
	$PseudoPet.sprite.set_sprite_frames(pet.sprite.sprite_frames)
	$PseudoPet.sprite.offset = pet.sprite.offset
	$PseudoPet.sprite.play("Quirk")
	updateGameText("3")
	mashMeter.initializeMeter(mashMax, mashGoal, mashGoalMax, 5)
	$Timer.start(1)
	gameRunning = true

func endGame():
	playMenu.closeMenu()
	queue_free()

func onWin():
	SfxManager.incrementMusic(1)
	gameRunning = false
	updateGameText("NOW!")
	$PseudoPet.hop()
	$Hammer.set_animation("Down")
	await get_tree().create_timer(1).timeout
	$Hammer.set_animation("Up")
	updateGameText("WIN!")
	$PseudoPet.hop(2)
	$PseudoPet.sprite.play("Quirk")
	connectedPet.receivePlay(joyIncrement, statToIncrease, statIncrement)
	await get_tree().create_timer(2).timeout
	endGame()

func onLose():
	SfxManager.incrementMusic(0)
	gameRunning = false
	updateGameText("LOSE!")
	$PseudoPet.sprite.play("Quirk")
	await get_tree().create_timer(2).timeout
	endGame()

func updateGameText(text : String):
	$Status.text = text


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
		$Timer.start(1)
	elif gameIteration == 0:
		gameIteration -= 1
		updateGameText("PREPARE!")
		$PseudoPet.sprite.play("Idle")
		$Timer.start(gameDuration)
		mashMode = true
	else:
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

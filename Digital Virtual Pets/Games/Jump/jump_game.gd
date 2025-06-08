extends Node2D

var implements = [Interface.MiniGame]

@onready var originalPosn : Vector2 = $PseudoPet.position

@export_category("Object References")
@export var background : Sprite2D
@export var hurdle : Sprite2D
@export_category("Game Values")
@export var joyIncrement : int
@export var statIncrement : int
@export var statToIncrease : Enums.AbilityStat
@export var speed : int
@export var jumpDuration : float
@export var repetitionRange : Vector2
@export var _minigameTheme : MusicTrack

var playMenu : Node2D
var connectedPet : Node2D
var gameRunning : bool
var reptetitions : int
var isJump : bool
var isRaise : bool

func _process(delta):
	if gameRunning:
		if hurdle.position.x > $BlankMenuSprite2/HurdleWrapEnd.position.x:
			hurdle.position.x -= (speed * 3) * delta
		else:
			if reptetitions > 0:
				hurdle.position.x = $BlankMenuSprite2/HurdleWrapStart.position.x
				reptetitions -= 1
			else:
				onWin()
		

func startGame(pet : Node2D, playMenu : Node2D):
	SfxManager.playMusic(_minigameTheme)
	speed *= Settings.gameScale
	$PseudoPet.AreaEntered.connect(onLose)
	$PseudoPet.TweenToFinished.connect(drop)
	connectedPet = pet
	self.playMenu = playMenu
	$PseudoPet.sprite.set_sprite_frames(pet.sprite.sprite_frames)
	$PseudoPet.sprite.offset = pet.sprite.offset
	$PseudoPet.setDirection(true)
	$PseudoPet.sprite.play("Walk")
	
	background.speed = speed
	
	randomize()
	reptetitions = randi_range(repetitionRange.x, repetitionRange.y)
	
	updateGameText("JUMP")

	gameRunning = true

func takeInput(input : Enums.InputType):
	if gameRunning:
		if input == Enums.DeviceButton.CENTER_BUTTON and not isJump:
			$PseudoPet.tweenToLocation($JumpHeight.position, jumpDuration * .5)
			isRaise = true
			isJump = true


func drop():
	if isRaise and isJump:
		isRaise = false
		await get_tree().create_timer(.5).timeout
		$PseudoPet.tweenToLocation(originalPosn, jumpDuration * .5)
	elif isJump:
		isJump = false



func onWin():
	SfxManager.incrementMusic(1)
	updateGameText("WIN!")
	gameRunning = false
	background.speed = 0
	print("You Win!")
	$PseudoPet.sprite.play("Quirk")
	connectedPet.receivePlay(joyIncrement, statToIncrease, statIncrement)
	await get_tree().create_timer(1).timeout
	endGame()

func onLose():
	SfxManager.incrementMusic(0)
	updateGameText("LOSE!")
	gameRunning = false
	background.speed = 0
	print("You Lose!")
	$PseudoPet.sprite.play("Quirk")
	await get_tree().create_timer(1).timeout
	endGame()

func endGame():
	playMenu.closeMenu()
	queue_free()

func updateGameText(text : String):
	$Status.text = text

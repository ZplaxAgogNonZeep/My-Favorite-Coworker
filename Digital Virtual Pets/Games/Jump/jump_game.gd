extends Minigame

var implements = [Interface.MiniGame]

@onready var originalPosn : Vector2 = $PseudoPet.position

@export_category("Object References")
@export var background : Sprite2D
@export var hurdle : Sprite2D
@export_category("Game Values")
@export var speed : int
@export var jumpDuration : float
@export var repetitionRange : Vector2

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
	super(pet, playMenu)
	$PseudoPet.AreaEntered.connect(onLose)
	$PseudoPet.TweenToFinished.connect(drop)
	speed *= Settings.gameScale
	$PseudoPet.setDirection(true)
	$PseudoPet.sprite.play("Walk")
	
	background.speed = speed
	
	randomize()
	reptetitions = randi_range(repetitionRange.x, repetitionRange.y)
	
	updateGameText("JUMP")

	gameRunning = true

func takeInput(input : Enums.DeviceButton):
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
	background.speed = 0
	gameRunning = false
	super()


func onLose():
	background.speed = 0
	gameRunning = false
	super()

extends Control

var implements = [Interface.MiniGame]

@export var joyIncrement : int
@export var statToIncrease : Enums.AbilityStat
@export var statIncrement : int
@export var gameTimerRange : Vector2
@export var catchWindowDuration : float

var playMenu : Panel
var connectedPet : Node2D
var gameRunning : bool
var isCatchWindow : bool
var catchWindowTimer : SceneTreeTimer

func startGame(pet : Node2D, playMenu : Panel):
	connectedPet = pet
	self.playMenu = playMenu
	$PseudoPet.sprite.set_sprite_frames(pet.sprite.sprite_frames)
	$PseudoPet.sprite.animation = "Idle"
	$FishingRod.play("Inactive")
	
	updateGameText("WAIT")
	
	randomize()
	var timerDuration = randi_range(gameTimerRange.x, gameTimerRange.y)
	print(timerDuration)
	$Timer.start(timerDuration)
	gameRunning = true

func updateGameText(text : String):
	$Status.text = text

func onWin():
	$FishingRod.play("ReeledIn")
	$Catch.visible = true
	updateGameText("WIN!")
	$PseudoPet.hop(2)
	connectedPet.receivePlay(joyIncrement, statToIncrease, statIncrement)
	await get_tree().create_timer(1).timeout
	endGame()

func onLose():
	$FishingRod.play("ReeledIn")
	updateGameText("LOSE")
	await get_tree().create_timer(1).timeout
	endGame()

func endGame():
	playMenu.closeMenu()
	queue_free()

func takeInput(input : Enums.InputType):
	if gameRunning:
		if input == Enums.InputType.MIDDLEBUTTON:
			$Timer.stop()
			$CatchWindow.stop()
			if isCatchWindow:
				onWin()
			else:
				onLose()

# Signals ==========================================================================================

func _on_timer_timeout():
	if gameRunning:
		isCatchWindow = true
		updateGameText("FISH")
		$FishingRod.play("Active")
		$CatchWindow.start(catchWindowDuration)

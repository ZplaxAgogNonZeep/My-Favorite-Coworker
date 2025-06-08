extends Node2D

var implements = [Interface.MiniGame]

@export var joyIncrement : int
@export var statToIncrease : Enums.AbilityStat
@export var statIncrement : int
@export var gameTimerRange : Vector2
@export var catchWindowDuration : float
@export var _minigameTheme : MusicTrack

var playMenu : Node2D
var connectedPet : Node2D
var gameRunning : bool
var isCatchWindow : bool
var catchWindowTimer : SceneTreeTimer

func startGame(pet : Node2D, playMenu : Node2D):
	SfxManager.playMusic(_minigameTheme)
	connectedPet = pet
	self.playMenu = playMenu
	$PseudoPet.sprite.set_sprite_frames(pet.sprite.sprite_frames)
	$PseudoPet.sprite.offset = pet.sprite.offset
	$PseudoPet.sprite.play("Idle")
	$FishingRod.play("Inactive")
	
	updateGameText("WAIT")
	
	randomize()
	var timerDuration = randi_range(gameTimerRange.x, gameTimerRange.y)
	$Timer.start(timerDuration)
	gameRunning = true

func updateGameText(text : String):
	$Status.text = text

func onWin():
	SfxManager.incrementMusic(1)
	$FishingRod.play("ReeledIn")
	$FishingRod/Catch.visible = true
	updateGameText("WIN!")
	$PseudoPet.sprite.play("Quirk")
	$PseudoPet.hop(2)
	connectedPet.receivePlay(joyIncrement, statToIncrease, statIncrement)
	await get_tree().create_timer(1).timeout
	endGame()

func onLose():
	SfxManager.incrementMusic(0)
	$FishingRod.play("ReeledIn")
	updateGameText("LOSE")
	$PseudoPet.sprite.play("Quirk")
	await get_tree().create_timer(1).timeout
	endGame()

func endGame():
	playMenu.closeMenu()
	queue_free()

func takeInput(input : Enums.DeviceButton):
	if gameRunning:
		gameRunning = false
		if input == Enums.DeviceButton.CENTER_BUTTON:
			$Timer.stop()
			$CatchWindow.stop()
			if isCatchWindow:
				onWin()
			else:
				onLose()

#region Signals

func _on_timer_timeout():
	if gameRunning:
		isCatchWindow = true
		updateGameText("FISH")
		$FishingRod.play("Active")
		$CatchWindow.start(catchWindowDuration)

#endregion

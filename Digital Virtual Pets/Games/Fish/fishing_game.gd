extends Minigame

var implements = [Interface.MiniGame]


@export var gameTimerRange : Vector2
@export var catchWindowDurations : Array[float]

var isCatchWindow : bool

func startGame(pet : Node2D, playMenu : Node2D):
	super(pet, playMenu)
	$PseudoPet.sprite.play("Idle")
	$FishingRod.play("Inactive")
	
	updateGameText("WAIT")
	
	randomize()
	var timerDuration = randi_range(gameTimerRange.x, gameTimerRange.y)
	$Timer.start(timerDuration)
	gameRunning = true


func onWin():
	$FishingRod.play("ReeledIn")
	$FishingRod/Catch.visible = true
	super()

func onLose():
	$FishingRod.play("ReeledIn")
	super()


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
		if (!isCatchWindow):
			isCatchWindow = true
			updateGameText("FISH")
			$FishingRod.play("Active")
			$Timer.start(catchWindowDurations[_difficulty])
		else:
			onLose()
		

#endregion

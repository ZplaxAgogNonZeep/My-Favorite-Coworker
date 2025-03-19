extends Panel

var implements = [Interface.MenuState]
enum PlayState {MENU, GAME}

@export var buttonController : Node
@export var miniGameList : Array[PackedScene]

var stateMachine : Node2D
var game : Control
var state = PlayState.MENU

func _ready():
	$GameMenu/Exit.ButtonSelected.connect(onExitSelected)
	$GameMenu/Guess.ButtonSelected.connect(onGuessSelected)
	$GameMenu/Fish.ButtonSelected.connect(onFishSelected)
	$GameMenu/Run.ButtonSelected.connect(onRunSelected)
	$GameMenu/Hit.ButtonSelected.connect(onHitSelected)
	$GameMenu/Endure.ButtonSelected.connect(onEndureSelected)
	

func initializeMenu():
	state = PlayState.MENU
	visible = true
	GameEvents.PauseGame.emit()
	buttonController.setActive(true)


func exitMenu():
	visible = false
	game = null
	buttonController.setActive(false)
	GameEvents.HopDeviceOnce.emit()
	GameEvents.HopDeviceOnce.emit()
	GameEvents.UnpauseGame.emit()

func closeMenu():
	stateMachine.setState(stateMachine.MenuState.MINIMIZED)

func takeInput(input : Enums.DeviceButton):
	match state:
		PlayState.MENU:
			match input:
				Enums.DeviceButton.CENTER_BUTTON:
					buttonController.select()
				Enums.DeviceButton.LEFT_BUTTON:
					buttonController.cycle(-1)
				Enums.DeviceButton.RIGHT_BUTTON:
					buttonController.cycle(1)
		PlayState.GAME:
			if game:
				game.takeInput(input)

func getPet():
	if (get_tree().get_nodes_in_group("Pet").size() > 0):
		return get_tree().get_nodes_in_group("Pet")[0]
	else:
		return null

func onExitSelected():
	closeMenu()

func onGuessSelected():
	print("Guess Game Selected")
	if getPet():
		game = miniGameList[0].instantiate()
		$MiniGameContainer.add_child(game)
		game.startGame(getPet(), self)
		state = PlayState.GAME
	else:
		print("COULD NOT FIND PET")

func onFishSelected():
	if getPet():
		game = miniGameList[1].instantiate()
		$MiniGameContainer.add_child(game)
		game.startGame(getPet(), self)
		state = PlayState.GAME
	else:
		print("COULD NOT FIND PET")

func onRunSelected():
	if getPet():
		game = miniGameList[2].instantiate()
		$MiniGameContainer.add_child(game)
		game.startGame(getPet(), self)
		state = PlayState.GAME
	else:
		print("COULD NOT FIND PET")

func onHitSelected():
	if getPet():
		game = miniGameList[3].instantiate()
		$MiniGameContainer.add_child(game)
		game.startGame(getPet(), self)
		state = PlayState.GAME
	else:
		print("COULD NOT FIND PET")

func onEndureSelected():
	if getPet():
		game = miniGameList[4].instantiate()
		$MiniGameContainer.add_child(game)
		game.startGame(getPet(), self)
		state = PlayState.GAME
	else:
		print("COULD NOT FIND PET")

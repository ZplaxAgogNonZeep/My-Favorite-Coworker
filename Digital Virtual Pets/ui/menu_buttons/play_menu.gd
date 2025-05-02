extends Node2D

var implements = [Interface.MenuState]
enum PlayState {MENU, GAME}

@export var _menuIndexContainer : Node2D
@export var _miniGameContainer : Node2D
@export var _gamePageList : Array[Node2D]
@export var miniGameList : Array[PackedScene]

var stateMachine : Node2D
var game : Node2D
var state = PlayState.MENU
var _menuIndex := 0

func _ready():
	pass


func initializeMenu():
	state = PlayState.MENU
	visible = true
	GameEvents.PauseGame.emit()
	#buttonController.setActive(true)
	for page in _gamePageList:
		page.visible = false
	_gamePageList[0].visible = true
	_menuIndex = 0
	for x in range(_menuIndexContainer.get_child_count()):
		_setVisualMenuIndex(x, false)
	_setVisualMenuIndex(0, true)


func exitMenu():
	visible = false
	game = null
	#buttonController.setActive(false)
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
					_select(_menuIndex)
				Enums.DeviceButton.LEFT_BUTTON:
					_cycle(-1)
				Enums.DeviceButton.RIGHT_BUTTON:
					_cycle(1)
		PlayState.GAME:
			if game:
				game.takeInput(input)


func getPet() -> Pet:
	if (PetManager.instance != null):
		return PetManager.instance.activePet
	else:
		return null


func _setVisualMenuIndex(index : int, active : bool):
	_menuIndexContainer.get_node("Index" + str(index)).frame = active
	

func _cycle(amount : int):
	_setVisualMenuIndex(_menuIndex, false)
	_gamePageList[_menuIndex].visible = false
	_menuIndex += amount
	
	if (_menuIndex >= _gamePageList.size()):
		_menuIndex = 0
	if (_menuIndex < 0):
		_menuIndex = _gamePageList.size() - 1
	
	_setVisualMenuIndex(_menuIndex, true)
	_gamePageList[_menuIndex].visible = true


func _select(index : int):
	if (index == _gamePageList.size() - 1):
		onExitSelected()
		return
	
	if getPet():
		game = miniGameList[_menuIndex].instantiate()
		_miniGameContainer.add_child(game)
		game.startGame(getPet(), self)
		state = PlayState.GAME
	else:
		print("COULD NOT FIND PET")

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

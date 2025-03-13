extends Node2D

var implements = [Interface.MenuState]

@export var buttonController : Node

var stateMachine : Node2D

func _ready():
	$Feed.ButtonSelected.connect(onFeedSelected)
	$Play.ButtonSelected.connect(onPlaySelected)
	$Stats.ButtonSelected.connect(onStatsSelected)
	GameEvents.NewPetSpawned.connect(_updateMenuButtons)
	GameEvents.NewPetEvolved.connect(_updateMenuButtons)

func initializeMenu():
		pass
	
func exitMenu():
		pass

func takeInput(input : Enums.InputType):
	if (buttonController.active):
		match input:
			Enums.InputType.LEFTBUTTON:
				buttonController.cycle(-1)
			Enums.InputType.RIGHTBUTTON:
				buttonController.cycle(1)
			Enums.InputType.MIDDLEBUTTON:
				buttonController.select()
	else:
		buttonController.setActive(true)


func _updateMenuButtons(isEgg : bool):
	$Play.toggleDisable(!isEgg)
	$Feed.toggleDisable(!isEgg)

func onFeedSelected():
	GameEvents.FeedPet.emit()


func onPlaySelected():
	stateMachine.setState(stateMachine.MenuState.PLAY)


func onStatsSelected():
	stateMachine.setState(stateMachine.MenuState.STATS)

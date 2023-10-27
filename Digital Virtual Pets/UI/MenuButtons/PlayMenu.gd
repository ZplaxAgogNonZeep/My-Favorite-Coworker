extends Panel

var implements = [Interface.MenuState]
enum PlayState {MENU, GAME}

@export var buttonController : Node

var stateMachine : Node2D

var state = PlayState.MENU


func initializeMenu():
	GameEvents.PauseGame.emit()


func exitMenu():
	GameEvents.UnpauseGame.emit()


func takeInput(input : Enums.InputType):
	match state:
		PlayState.MENU:
			pass
		PlayState.GAME:
			pass

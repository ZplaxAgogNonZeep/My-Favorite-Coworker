extends Node2D
var implements = [Interface.MenuState]

@export var _displayScreen : AnimatedSprite2D
@export var _overlay : AnimatedSprite2D

var stateMachine : Node2D
	
func initializeMenu():
	_displayScreen.play("Transition In")
	await _displayScreen.animation_finished
	visible = true
	_overlay.play("Evolve Menu")
	_displayScreen.play("Transition Out")

func exitMenu():
	await GameEvents.NewPetEvolved
	_displayScreen.play("Transition In")
	await _displayScreen.animation_finished
	visible = false
	_displayScreen.play("Transition Out")

func takeInput(input : Enums.InputType):
	if (input == Enums.DeviceButton.CENTER_BUTTON):
		stateMachine.setState(stateMachine.MenuState.MINIMIZED)
		

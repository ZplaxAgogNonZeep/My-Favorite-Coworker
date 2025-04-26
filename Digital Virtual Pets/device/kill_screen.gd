extends Node2D

var implements = [Interface.MenuState]

@export var _pseudoPet : PseudoPet
@export var _crossSprite : AnimatedSprite2D
@export var _ageLabel : Label
var stateMachine : Node2D

func initializeMenu(petData):
	GameEvents.PauseGame.emit()
	_pseudoPet.sprite.sprite_frames = petData.petResource.spriteFrames
	var age = Lifespan.convertLifespanToAge(petData.age)
	_ageLabel.text = "Age:\n"  + str(age[0]) + "d " + str(age[1]) + "h " + str(age[2]) + "m"
	_crossSprite.play()
	
	visible = true

func exitMenu():
	visible = false

func takeInput(input : Enums.InputType):
	GameEvents.OpenDirectMenu.emit(2)
	stateMachine.setState(stateMachine.MenuState.MINIMIZED)

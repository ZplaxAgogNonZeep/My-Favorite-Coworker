extends Node2D

var implements = [Interface.MenuState]

@export var _pseudoPet : PseudoPet
@export var _crossSprite : AnimatedSprite2D
@export var _ageLabel : Label
var stateMachine : Node2D

func initializeMenu(petData):
	Settings.pauseGame(true)
	_pseudoPet.sprite.sprite_frames = petData.petResource.spriteFrames
	var age = Lifespan.convertLifespanToAge(petData.age)
	_ageLabel.text = "Age:\n"  + str(int(age[0])) + "d " + str(int(age[1])) + "h " + str(int(age[2])) + "m"
	_crossSprite.play()
	
	visible = true

func exitMenu():
	visible = false

func takeInput(input : Enums.InputType):
	GameEvents.OpenDirectMenu.emit(2)
	stateMachine.setState(stateMachine.MenuState.MINIMIZED)

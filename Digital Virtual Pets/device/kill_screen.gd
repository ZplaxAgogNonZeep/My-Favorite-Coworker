extends Node2D

var implements = [Interface.MenuState]

@export var _pseudoPet : PseudoPet
@export var _crossSprite : AnimatedSprite2D
@export var _ageLabel : Label
var stateMachine : Node2D
var _menuOpened := false

func initializeMenu(petData):
	GameEvents.PauseTimers.emit()
	_pseudoPet.sprite.sprite_frames = petData.petResource.spriteFrames
	var age = Lifespan.convertLifespanToAge(petData.age)
	_ageLabel.text = "Age:\n"  + str(int(age[0])) + "d " + str(int(age[1])) + "h " + str(int(age[2])) + "m"
	_crossSprite.play()
	_menuOpened = false
	visible = true


func exitMenu():
	visible = false
	GameEvents.UnpauseTimers.emit()

func takeInput(input : Enums.InputType):
	if (!_menuOpened):
		_menuOpened = true
		GameEvents.OpenDirectMenu.emit(2)
		#TODO: Figure out how to delay this step a lil
		stateMachine.setState(stateMachine.MenuState.MINIMIZED)

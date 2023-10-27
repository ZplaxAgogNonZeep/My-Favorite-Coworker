extends Panel

var implements = [Interface.MenuState]

var stateMachine : Node2D

func takeInput(input : Enums.InputType):
	if (input == Enums.InputType.MIDDLEBUTTON):
		closeMenu()
	


func closeMenu():
	pass

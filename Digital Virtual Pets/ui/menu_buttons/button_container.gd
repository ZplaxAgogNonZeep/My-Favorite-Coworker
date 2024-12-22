extends Node

@export var buttonArray : Array[Control] = []

var index := 0
var active := false

func setActive(isActive : bool):
	active = isActive
	
	for x in range(buttonArray.size()):
		if (Interface.hasInterface(buttonArray[x], Interface.HighlightButton) and buttonArray[x].isEnabled):
			index = x
			break
		
	buttonArray[index].toggleHighlight(isActive)


func cycle(value : int):
	for child in range(buttonArray.size()):
		if Interface.hasInterface(buttonArray[child], Interface.HighlightButton):
			if buttonArray[child].isEnabled:
				break
	
	if (buttonArray[index].implements.has(Interface.HighlightButton)):
		buttonArray[index].toggleHighlight(false)
	
	index += value
	
	if index >= buttonArray.size():
		index = 0
	elif index < 0:
		index = buttonArray.size() - 1
	
	if (buttonArray[index].implements.has(Interface.HighlightButton) and buttonArray[index].isEnabled):
		buttonArray[index].toggleHighlight(true)
	else:
		cycle(value)

func select():
	if (buttonArray[index].implements.has(Interface.HighlightButton)):
		buttonArray[index].selectButton()
		
		setActive(false)

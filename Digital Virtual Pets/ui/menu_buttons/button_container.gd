extends Node

@export var buttonArray : Array[Control] = []

var index := 0
var active := false

func setActive(isActive : bool):
	active = isActive
	
	if (buttonArray[index].implements.has(Interface.HighlightButton)):
		buttonArray[index].toggleHighlight(isActive)


func cycle(value : int):
	if (buttonArray[index].implements.has(Interface.HighlightButton)):
		buttonArray[index].toggleHighlight(false)
	
	index += value
	
	if index >= buttonArray.size():
		index = 0
	elif index < 0:
		index = buttonArray.size() - 1
	
	if (buttonArray[index].implements.has(Interface.HighlightButton)):
		buttonArray[index].toggleHighlight(true)

func select():
	if (buttonArray[index].implements.has(Interface.HighlightButton)):
		buttonArray[index].selectButton()
		
		setActive(false)

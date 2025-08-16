extends Node2D

class_name StatusBar

var heartObjects : Array = []

func _ready():
	for child in get_children():
		heartObjects.append(child)


func updateBar(fillAmount : int, maxValue : int):
	var segmentAmount : int = maxValue / heartObjects.size()
	var fillValue : float = float(maxValue) / (float(heartObjects.size()) * 2)
	print(fillValue)
	var count = 0
	for child in heartObjects:
		if fillAmount >= fillValue * ((count + 1) * 2):
			child.animation = "Full"
		else:
			if fillAmount >= (fillValue * ((count + 1) * 2)) - fillValue:
				child.animation = "Half Full"
			else:
				child.animation = "Empty"
		
		count += 1

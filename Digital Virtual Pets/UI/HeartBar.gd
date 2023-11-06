extends Node2D

var heartObjects : Array = []

func _ready():
	for child in get_children():
		heartObjects.append(child)


func updateBar(fillAmount : int, maxValue : int):
	var segmentAmount : int = maxValue / heartObjects.size()
	
	var count = 0
	print("Updating bar with ", fillAmount, " / ", maxValue)
	for child in heartObjects:
		if fillAmount >= segmentAmount * (count + 1):
			child.animation = "Full"
		else:
			if fillAmount >= ((segmentAmount) * .5) + (segmentAmount * count):
				child.animation = "Half Full"
			else:
				child.animation = "Empty"
		
		count += 1

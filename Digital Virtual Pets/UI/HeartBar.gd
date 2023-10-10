extends Node2D

@export_category("Read Only")
@export var DEBUG_fill := 0
@export var DEBUG_max := 0

var heartObjects : Array = []

func _ready():
	for child in get_children():
		heartObjects.append(child)


func updateBar(fillAmount : int, maxValue : int):
	DEBUG_max = maxValue
	DEBUG_fill = fillAmount
	
	var segmentAmount : int = maxValue / heartObjects.size()
	
	var count = 0
	for child in heartObjects:
		if fillAmount >= segmentAmount * (count + 1):
			child.animation = "Full"
		else:
			if fillAmount >= ((segmentAmount) * .5) + (segmentAmount * count):
				child.animation = "Half Full"
			else:
				child.animation = "Empty"
		
		count += 1

extends VBoxContainer

class_name ChartBuilder

@export var _testResource : PetTypeData
@export_category("Node References")
@export var _categories : Array[Control]
@export_category("Prefabs")
@export var _petIconScene : PackedScene
@export_category("Settings")
@export var _nodeSpacing : Vector2
@export var _horizontalSpacer : float

func _ready() -> void:
	_generateTree(_testResource)

## Takes [param eggData] and extrapolates a Linked List of evolutions from it.
## The linked list is then used to generate a horizontal tree graph. Each node in the tree should be
## positioned as follows: all originate from the default position, (i.e the egg node position). 
## all nodes should be aligned to predetermined column positions based on the pet's stage. All pets in
## a stage should be spaced vertically as such: Even is half of a point away from start, Odds should 
## Start at the same as origin and space from there, creating an alternating pattern in the grid.
func _generateTree(eggData : PetTypeData) -> void:
	# Define a list of lists for all of the resources we need, as well as all of the node positions
	var stages : Array[Array] # Array of arrays for resources
	var nodePositions : Array[Array] # Array of arrays for each nodes positions relative to the origin
	for x in range(0, 4):
		stages.append([])
		nodePositions.append([])
	
	# Fille in stages using a recursive function that goes down the tree and adds everything in.
	stages[0].append(eggData)
	var currentPet := eggData
	_r_generateTree(eggData, stages)
	print(stages, "\n------------------------------")
	
	# Define the actual positions for each node in the tree
	var stageCount = 0
	for stage in stages:
		print("stage ", stageCount)
		# Make a nulled out list that will mirror the stage variable
		for pet in stage:
			nodePositions[stageCount].append(Vector2.ZERO)
		
		# For each stage, define a starting index in the middle of the list, and work from there
		# to build up positions
		var isEven = stage.size() % 2 == 0
		var startingIndex = 0
		if (stage.size() > 1):
			if (isEven):
				startingIndex = int((stage.size() * .5))
			else:
				startingIndex = floori(stage.size() * .5)
		
		var currentIndex = startingIndex
		var count = 0
		while count < stage.size():
			
			var newPosn = Vector2.ZERO
			var distanceFromStart : int
			var dir = 1
			if currentIndex >= startingIndex:
				distanceFromStart = currentIndex - startingIndex
				if (distanceFromStart == 0 and isEven):
					distanceFromStart = 1
				dir *= -1
			else:
				distanceFromStart = startingIndex - currentIndex
			
			
			if currentIndex < stage.size():
				print(currentIndex)
				newPosn.x = (_nodeSpacing.x * stage[currentIndex].stage) + _horizontalSpacer
				if isEven:
					newPosn.y = ((((_nodeSpacing.y + 16) * (distanceFromStart)))) * dir
				else:
					newPosn.y = (((_nodeSpacing.y + 32) * (distanceFromStart))) * dir

				nodePositions[stageCount][currentIndex] = newPosn
				currentIndex += 1
				count += 1
			else:
				currentIndex = 0
		
		stageCount += 1
	
	print(nodePositions)


## A Recursive function that takes [param petData] and a running array, [param stages], then uses
## the linked list within [param petData] and works through it to fill in [param stages].
func _r_generateTree(petData : PetTypeData, stages : Array[Array]) -> void:
	for evolution : PetTypeData in petData.evolutions:
		if (!stages[evolution.stage].has(evolution)):
			stages[evolution.stage].append(evolution)
			_r_generateTree(evolution, stages)

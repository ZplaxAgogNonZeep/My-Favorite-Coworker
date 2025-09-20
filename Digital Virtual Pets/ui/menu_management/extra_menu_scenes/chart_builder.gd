extends VBoxContainer

class_name ChartBuilder

signal FillBioData(petData : PetTypeData)

@export var _testResource : PetTypeData
@export_category("Node References")
@export var _categories : Array[Control]
@export_category("Prefabs")
@export var _petIconScene : PackedScene
@export_category("Settings")
@export var _nodeSpacing : Vector2
@export var _horizontalSpacer : float
@export var _parallelLineColor : Color

## Takes [param eggData] and extrapolates a Linked List of evolutions from it.
## The linked list is then used to generate a horizontal tree graph. Each node in the tree should be
## positioned as follows: all originate from the default position, (i.e the egg node position). 
## all nodes should be aligned to predetermined column positions based on the pet's stage. All pets in
## a stage should be spaced vertically as such: Even is half of a point away from start, Odds should 
## Start at the same as origin and space from there, creating an alternating pattern in the grid.
func generateTree(eggData : PetTypeData, encounteredPets : Dictionary[String, PetTypeData]) -> void:
	# Define a list of lists for all of the resources we need, as well as all of the node positions
	print(eggData, " =============================================================")
	
	var stages : Array[Array] # Array of arrays for resources
	var nodePositions : Array[Array] # Array of arrays for each nodes positions relative to the origin
	for x in range(0, 4):
		stages.append([])
		nodePositions.append([])
	
	# Fille in stages using a recursive function that goes down the tree and adds everything in.
	stages[0].append(eggData)
	var currentPet := eggData
	_r_generateTree(eggData, stages)
	
	# Define the actual positions for each node in the tree
	var stageCount = 0
	for stage in stages:
		print(stage, " -------------------")
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
		print(isEven, " Starting Index: ", startingIndex)
		
		var currentIndex = startingIndex
		var count = 0
		while count < stage.size():
			# Loop through each pet in a stage and determine it's position
			var newPosn = Vector2.ZERO
			var distanceFromStart : int
			var dir = 1
			# Check which part of the list we're in and thus what direction the position goes in
			# and how far we are from the origin point
			if currentIndex >= startingIndex:
				distanceFromStart = currentIndex - startingIndex
				if (isEven):
					distanceFromStart += 1
				#if (distanceFromStart == 0 and isEven):
					#distanceFromStart = 1
			else:
				distanceFromStart = startingIndex - currentIndex
				dir *= -1
			
			# If the current index is whithin the array, we proceed, otherwise we set it to zero
			if currentIndex < stage.size():
				newPosn.x = (_nodeSpacing.x * stage[currentIndex].stage) + _horizontalSpacer
				if isEven:
					if (distanceFromStart > 1):
						newPosn.y = ((((_nodeSpacing.y + 24) * (distanceFromStart)))) * dir
					else:
						newPosn.y = ((((_nodeSpacing.y + 16) * (distanceFromStart)))) * dir
				else:
					newPosn.y = (((_nodeSpacing.y + 32) * (distanceFromStart))) * dir
				if (stage.size() == 4):
					print(stage[currentIndex] , " = ", newPosn.y, " (index: ", currentIndex, " distanceFromStart: ", distanceFromStart,")")

				nodePositions[stageCount][currentIndex] = newPosn
				currentIndex += 1
				count += 1
			else:
				currentIndex = 0
		
		stageCount += 1
	
	# Time to start creating nodes and building them
	var container : Control = Control.new()
	var height = nodePositions[0][0].y + _nodeSpacing.y + 32
	
	# first we need to establish a minimum y size by finding the highest column in the tree
	for stage in nodePositions:
		if stage.size() > 1:
			var spacingTotal = _nodeSpacing.y * stage.size()
			if (abs(stage[0].y) + abs(stage[stage.size() - 1].y) + (_nodeSpacing.y * stage.size()) + 32 > height):
				height = abs(stage[0].y) + abs(stage[stage.size() - 1].y) + (_nodeSpacing.y * stage.size()) + 32
	
	container.custom_minimum_size.y = height
	
	# Now we go through every pet, create a button for it, give it all the appropriate details
	# and offset it accordingly
	for stageIndex in range(stages.size()):
		for petIndex in range(stages[stageIndex].size()):
			var newNode = _petIconScene.instantiate()
			newNode.petData = stages[stageIndex][petIndex]
			# Set Icon
			var tex = CanvasTexture.new()
			var tex2 = ImageTexture.new()
			var image : Image = stages[stageIndex][petIndex].getSpriteIcon().get_image()
			tex2.set_image(image)
			
			tex.diffuse_texture = tex2
			tex.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			newNode.icon = tex
			newNode.setSilhouette(tex)
			newNode.TreeNodePressed.connect(_updateAllToggleButtons)
			
			if (!encounteredPets.has(stages[stageIndex][petIndex].name)):
				newNode.toggleSilhouette(true)
				newNode.setName("???")
				newNode.disabled = true
			else:
				newNode.setName(stages[stageIndex][petIndex].name)
			
			newNode.position = (Vector2(0, container.custom_minimum_size.y * .5) + 
								nodePositions[stageIndex][petIndex]) - Vector2(0, 16)
			
			container.call_deferred("add_child", newNode)
	
	call_deferred("add_child", container)
	
	# Now to finish we just need to go through each icon and set up the connecting evolution
	# lines
	
	await get_tree().process_frame
	
	var children = container.get_children().duplicate(true)
	for child in children:
		for evolution in child.petData.evolutions:
			var newLine = Line2D.new()
			newLine.default_color = Color.BLACK
			newLine.width = 2
			newLine.add_point(child.getLineMarker(true))
			newLine.add_point(getNodeByResource(container, evolution).getLineMarker(false))
			container.call_deferred("add_child", newLine)
		var count = 0
		for parallelEvo in child.petData.parallelEvolutions:
			var newLine = Line2D.new()
			newLine.default_color = _parallelLineColor
			newLine.width = 10
			if (count == 0):
				newLine.add_point(child.getParallelMarker(true))
				newLine.add_point(getNodeByResource(container, parallelEvo).getParallelMarker(false))
			if (count > 0):
				newLine.add_point(child.getParallelMarker(false))
				newLine.add_point(getNodeByResource(container, parallelEvo).getParallelMarker(true))
			#newLine.add_point(getNodeByResource(container, evolution).getLineMarker(false))
			container.call_deferred("add_child", newLine)
			count += 1

#region Utility Functions
## A Recursive function that takes [param petData] and a running array, [param stages], then uses
## the linked list within [param petData] and works through it to fill in [param stages].
func _r_generateTree(petData : PetTypeData, stages : Array[Array]) -> void:
	if petData.evolutions.size() > 0:
		for evolution : PetTypeData in petData.evolutions:
			if (!stages[evolution.stage].has(evolution)):
				stages[evolution.stage].append(evolution)
				_r_generateTree(evolution, stages)
	if petData.parallelEvolutions.size() > 0:
		var count = 0
		for parallelEvo in petData.parallelEvolutions:
			if (!stages[parallelEvo.stage].has(parallelEvo)):
				var index = stages[parallelEvo.stage].find(petData)
				if (count == 0):
					stages[parallelEvo.stage].insert(index, parallelEvo)
				else:
					if (index != stages[parallelEvo.stage].size() and index != -1):
						stages[parallelEvo.stage].insert(index + 1, parallelEvo)
					else:
						stages[parallelEvo.stage].append(parallelEvo)
				_r_generateTree(parallelEvo, stages)
			count += 1


func getNodeByResource(treeContainer : Control, petData : PetTypeData) -> Control:
	var children = treeContainer.get_children()
	
	for child in children:
		if child is Button:
			if (child.petData == petData):
				return child
	
	return null


func _updateAllToggleButtons(petData : PetTypeData):
	FillBioData.emit(petData)
	for container in get_children():
		if container is Control:
			for node in container.get_children():
				if (node is Button):
					if node.petData != petData:
						node.set_pressed_no_signal(false)
#endregion

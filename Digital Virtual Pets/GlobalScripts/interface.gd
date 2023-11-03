extends Node

class PetType:
	var petName : String
	
	func roamBehavior():
		pass
	
	func feedingBehavior():
		pass
	
	func onTickHunger():
		pass
	
	func onTickJoy():
		pass
	
	func onEatFood():
		pass
	
	func getEvolvePet():
		return null

class Food:
	var feedAmount : int


class HighlightButton:
	var isHighlighted
	
	func initializeButton():
		pass
	
	func toggleHighlight():
		pass
	
	func selectButton():
		pass

class MenuState:
	var stateMachine : Node2D
	
	func initializeMenu():
		pass
	
	func exitMenu():
		pass
	
	func takeInput(input : Enums.InputType):
		pass

class MiniGame:
	var gameRunning : bool
	var joyIncrement : int
	var statIncrement : int
	
	func startGame(pet : Node2D):
		pass
	
	func endGame():
		pass
	
	func takeInput(input : Enums.InputType):
		pass

# General Function =================================================================================

func _ready():
	var allLoadedNodes = getAllDecendants(get_tree().root)
	
	for node in allLoadedNodes:
		check_node(node)
	
	get_tree().node_added.connect(check_node)

func getAllDecendants(node):
	var allDecendants = [node]
	
	var children = node.get_children()
	for child in children:
		allDecendants.append_array(getAllDecendants(child))
	
	return allDecendants

func check_node(node):
	if "implements" in node:
		for interface in node.implements:
			var instance = interface.new()
			
			for method in instance.get_script().get_script_method_list():
				#print(method)
				assert(method.name in node, "Interface error: " + node.name + 
				" does not contain a function named " + method.name)
				#print(method.args)
			
			for property in instance.get_script().get_script_property_list():
				if (property.name != "Built-in script"):
					assert(property.name in node, "Interface error: " + node.name + 
					" does not contain a function named " + property.name)

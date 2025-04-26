extends Node

#region Interfaces

class Food:
	var feedAmount : int
	var readyToEat : bool


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
	@export var joyIncrement : int
	@export var statIncrement : int
	var playMenu : Panel
	var connectedPet : Node2D
	var gameRunning : bool
	
	func startGame(pet : Node2D, playMenu : Panel):
		pass
	
	func endGame():
		pass
	
	func takeInput(input : Enums.InputType):
		pass

#endregion

#region Quality of Life Functions

# Checks if the given object inherits the given class
# objectToCheck : Any node | interface : The class to check for
# ex. Interface.hasInterface(Player, Interface.Damageable)
func hasInterface(objectToCheck, interface) -> bool:
	if "implements" in objectToCheck:
		for objectInterface in objectToCheck.implements:
			if objectInterface == interface:
				return true
	
	return false

#endregion

#region General Function 

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
				assert(method.name in node, "Interface error: " + node.name + 
				" does not contain a function named " + method.name)
			
			for property in instance.get_script().get_script_property_list():
				if (property.name != "Built-in script"):
					assert(property.name in node, "Interface error: " + node.name + 
					" does not contain a function named " + property.name)

#endregion

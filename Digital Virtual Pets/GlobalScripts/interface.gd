extends Node

class PetType:
	var petName : String
	
	func roamBehavior():
		pass
	
	func onTickHunger():
		pass
	
	func onTickJoy():
		pass



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

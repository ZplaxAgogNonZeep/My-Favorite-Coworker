@tool
extends Node

@export_tool_button("Import Pet Data")
var x: Callable = _fillPetData
@export var _rootFilepath : String


func _fillPetData():
	
	
	print("Pet Data Import Complete")

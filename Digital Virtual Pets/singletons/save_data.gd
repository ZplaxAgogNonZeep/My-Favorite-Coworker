extends Node

const SETTINGS_FILEPATH := "user://settings.ini"
const GAMEDATA_FILEPATH := "user://gamedata.ini"

class Data:
	var category : String
	var properties : Dictionary

class DataSaver:
	var obj : Node
	var categoryName : String
	
	func DataSaver(_obj, _categoryName):
		obj = _obj
		categoryName = _categoryName
	
	func getDataToSave() -> Data:
		var data = Data.new()
		data.category = categoryName
		for property : Dictionary in get_property_list():
			if (property["name"] == "Built-in script" or property["name"] == "RefCounted" 
				or property["name"] == "script" or property["name"] == "obj"
				or property["name"] == "categoryName"):
				continue
			data.properties[property["name"]] = obj.get(property["name"])
		
		return data
	
	func setDataToLoad():
		pass
	

var _loadedSaveData : Array[Data]
var _subscribedSaveObjects

func _ready() -> void:
	# go through the game setting up everything for saving and loading
	var allLoadedNodes = _getAllDecendants(get_tree().root)
	
	for node in allLoadedNodes:
		_check_node(node)


#region Settings Data Handling
func saveSettingsToFile(dataDict : Dictionary):
	var config = ConfigFile.new()
	
	for key in dataDict.keys():
		config.set_value("Settings", key, dataDict[key])
	
	config.save(SETTINGS_FILEPATH)


func loadSettingsFromFile():
	var config = ConfigFile.new()
	
	var err = config.load(SETTINGS_FILEPATH)
	
	if err != OK:
		print("No Setting Save Data Found, using defaults")
		return
	
	var section = config.get_sections()[0]
	
	for key in config.get_section_keys(section):
		Settings.set(key, config.get_value(section, key))
	
#endregion

#region Game Data Handling
func saveGameToFile():
	var password = OS.get_unique_id()
	
	var config = ConfigFile.new()
	var dataToSave = []
	
	for savingObject in _subscribedSaveObjects:
		var dataSaver : DataSaver = savingObject.DataSaver.new()
		var data = dataSaver.getDataToSave()
		dataToSave.append(data)
	
	for data in dataToSave:
		var existingDataIndex = _checkForExistingCategory(data)
		if (existingDataIndex >= 0):
			_loadedSaveData.remove_at(existingDataIndex)
	
	_loadedSaveData.append_array(dataToSave)
	
	for data in _loadedSaveData:
		for propertyKey in data.properties.keys():
			config.set_value(data.category, propertyKey, data.properties[propertyKey])
	
	config.save_encrypted_pass(GAMEDATA_FILEPATH, password)


func loadGameFromFile():
	_loadedSaveData = []
	var password = OS.get_unique_id()
	var config = ConfigFile.new()
	var err = config.load_encrypted_pass(GAMEDATA_FILEPATH, password)
	
	if err != OK:
		print("No Setting Save Data Found, using defaults")
		return
	
	var sections = config.get_sections()
	
	for category in sections:
		var data := Data.new()
		data.category = category
		for propertyKey in config.get_section_keys(category):
			data.properties[propertyKey] = config.get_value(category, propertyKey)
		
		_loadedSaveData.append(data)

#endregion

#region Utility Functions
func _checkForExistingCategory(data: Data) -> int:
	var count = 0
	for existingData : Data in _loadedSaveData:
		if existingData.category == data.category:
			return count
		count += 1
	
	return -1


func _getAllDecendants(node : Node):
	var allDecendants = [node]
	
	var children = node.get_children()
	for child in children:
		allDecendants.append_array(_getAllDecendants(child))
	
	return allDecendants


func _check_node(node : Node):
	if ("DataSaver" in node):
		_subscribedSaveObjects += [node]

#endregion

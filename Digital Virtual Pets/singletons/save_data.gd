extends Node

const SETTINGS_FILEPATH := "user://settings.ini"
const GAMEDATA_FILEPATH := "user://gamedata.ini"
const DEBUGDATA_FILEPATH := "user://debugdata.ini"
const LAST_COMPATIBLE_VERSION := "0.3.2"

#region Data Saving Classes
class SavableClass:
	## Godot 4.3 has a bug where you can't load instantiated classes despite it being
	## able to save the data just fine, so when implementing a custom class to store
	## save data, use this class to give it the ability to convert to a dict
	func convertClassToDict() -> Dictionary:
		var classDict : Dictionary
		for property : Dictionary in get_property_list():
			if (property["name"] == "Built-in script" or property["name"] == "RefCounted" 
				or property["name"] == "script"):
				continue
			classDict[property["name"]] = get(property["name"])
		return classDict

class Data:
	var category : String
	var properties : Dictionary

class DataSaver:
	var obj : Node
	
	func getCategoryName() -> String:
		return ""
	
	func _init(_obj: Node) -> void:
		obj = _obj
	
	func getDataToSave() -> Data:
		var data = Data.new()
		data.category = getCategoryName()
		for property : Dictionary in get_property_list():
			if (property["name"] == "Built-in script" or property["name"] == "RefCounted" 
				or property["name"] == "script" or property["name"] == "obj"
				or property["name"] == "categoryName"):
				continue
			
			data.properties[property["name"]] = obj.get(property["name"])
		
		return data
	
	func setDataToLoad(data : Data) -> void:
		for property : Dictionary in get_property_list():
			if data.properties.has(property["name"]):
				#if (obj.get(property["name"]).has("SAVESYSTEM: DICT IS CONVERTED FROM CLASS")):
					#for propertyKey in obj.get(property["name"]).keys():
						#obj.set(property["name"][propertyKey], )
				obj.set(property["name"], data.properties[property["name"]])

#endregion

var _loadedSaveData : Array[Data]
var _subscribedSaveObjects : Array[Node]

func _ready() -> void:
	loadSettingsFromFile()
	loadGameFromFile()
	
	findAllDataSaversInScene()


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


func deleteSettingsSaveData():
	DirAccess.remove_absolute(SETTINGS_FILEPATH)
	saveGameToFile()
	get_tree().quit()

#endregion

#region Game Data Handling
func saveGameToFile():
	var password = OS.get_unique_id()
	
	var config = ConfigFile.new()
	var dataToSave = []
	
	for savingObject in _subscribedSaveObjects:
		var dataSaver : DataSaver = savingObject.DataSaver.new(savingObject)
		var data = dataSaver.getDataToSave()
		dataToSave.append(data)
	
	for data in dataToSave:
		var existingDataIndex = _checkForExistingCategory(data)
		if (existingDataIndex >= 0):
			_loadedSaveData.remove_at(existingDataIndex)
	
	_loadedSaveData.append_array(dataToSave)
	
	config.set_value("Game Information", "version", ProjectSettings.get_setting("application/config/version"))
	
	for data in _loadedSaveData:
		for propertyKey in data.properties.keys():
			config.set_value(data.category, propertyKey, data.properties[propertyKey])
	
	config.save_encrypted_pass(GAMEDATA_FILEPATH, password)
	if (Engine.is_editor_hint()):
		config.save(DEBUGDATA_FILEPATH)


func loadGameFromFile():
	_loadedSaveData = []
	var password = OS.get_unique_id()
	var config = ConfigFile.new()
	var err = config.load_encrypted_pass(GAMEDATA_FILEPATH, password)
	
	if err != OK:
		print("No Game Save Data Found, assuming new game")
		return
	
	
	var sections = config.get_sections()
	
	for category in sections:
		if category == "Game Information":
			config.get_value("Game Information", "version")
		var data := Data.new()
		data.category = category
		for propertyKey in config.get_section_keys(category):
			if config.get_value(category, propertyKey) is Object:
				print(category,": ", config.get_value(category, propertyKey))
			data.properties[propertyKey] = config.get_value(category, propertyKey)
		
		_loadedSaveData.append(data)


func deleteGameSaveData():
	DirAccess.remove_absolute(GAMEDATA_FILEPATH)
	get_tree().quit()


func retrieveGameData(category : String) -> Data:
	for data : Data in _loadedSaveData:
		if (category == data.category):
			return data
	
	return null


func findAllDataSaversInScene():
	if (_subscribedSaveObjects.size() > 0):
		_subscribedSaveObjects.clear()
	
	var allLoadedNodes = _getAllDecendants(get_tree().root)
	
	for node in allLoadedNodes:
		if ("DataSaver" in node):
			_subscribedSaveObjects += [node]
			var dataSaver : DataSaver = node.DataSaver.new(node)
			if (_loadedSaveData.size() > 0):
				var data = retrieveGameData(dataSaver.getCategoryName())
				if (data):
					dataSaver.setDataToLoad(data)

#endregion

#region Utility Functions

func isSaveDataExists(isSettings : bool) -> bool:
	if (isSettings):
		return DirAccess.dir_exists_absolute(SETTINGS_FILEPATH)
	else:
		return DirAccess.dir_exists_absolute(GAMEDATA_FILEPATH)


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

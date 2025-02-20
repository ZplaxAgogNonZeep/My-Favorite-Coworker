extends Node

const SETTINGS_FILEPATH := "user://settings.ini"

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
## Figuring this one out later lol - AMWB
func saveGameToFile():
	pass
#endregion

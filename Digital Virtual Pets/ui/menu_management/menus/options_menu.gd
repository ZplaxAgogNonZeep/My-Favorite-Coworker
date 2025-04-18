extends Menu

@export_category("Node References")
@export var _proactivityCheckbox : CheckBox
@export var _windowAttentionSelection : OptionButton
@export var _windowOrientationOptions : OptionButton
@export var _monitorOptions : OptionButton

func _loadSavedMenuSettings():
	_proactivityCheckbox.button_pressed = Settings.isUsingProactivity
	_windowAttentionSelection.selected = Settings.windowAttentionMode
	_windowOrientationOptions.selected = Settings.windowOrientation
	_monitorOptions.clear()
	_fillMonitorOptions(_monitorOptions, Settings.getMonitorCount())
	_monitorOptions.selected = Settings.activeMonitor


#region Signal Functions
func _onProactivityToggle(toggle: bool):
	Settings.setProactivitySetting(toggle)


func _onSetWindowAttention(index: int):
	Settings.setWindowAttentionMode(index)


func _onWindowOrientationOptions(index : int):
	Settings.setWindowOrientation(index)


func _onMonitorOptions(index : int):
	Settings.changeActiveMonitor(index)
#endregion

#region Helper Functions
func _fillMonitorOptions(options : OptionButton, monitorCount : int) -> void:
	for x in range(monitorCount):
		options.add_item("Display " + str(x))
#endregion

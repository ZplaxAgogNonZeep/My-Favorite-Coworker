extends Menu

@export_category("Node References")
@export var _proactivityCheckbox : CheckBox
@export var _windowAttentionSelection : OptionButton

func _loadSavedMenuSettings():
	_proactivityCheckbox.button_pressed = Settings.isUsingProactivity
	print(Settings.isUsingProactivity)
	_windowAttentionSelection.selected = Settings.windowAttentionMode


func _onProactivityToggle(toggle: bool):
	Settings.setProactivitySetting(toggle)

func _onSetWindowAttention(index: int):
	Settings.setWindowAttentionMode(index)

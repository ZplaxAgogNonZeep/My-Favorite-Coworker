extends Menu

@export_category("Node References")
@export var _proactivityCheckbox : CheckBox
@export var _windowAttentionSelection : OptionButton
@export var _windowOrientationOptions : OptionButton
@export var _monitorOptions : OptionButton
@export var _frameOptions : OptionButton
@export var _masterVolumeBar : HSlider
@export var _gameVolumeBar : HSlider
@export var _deviceVolumeBar : HSlider

func _loadSavedMenuSettings():
	_proactivityCheckbox.button_pressed = Settings.isUsingProactivity
	_windowAttentionSelection.selected = Settings.windowAttentionMode
	_windowOrientationOptions.selected = Settings.windowOrientation
	_monitorOptions.clear()
	_fillMonitorOptions(_monitorOptions, Settings.getMonitorCount())
	_monitorOptions.selected = Settings.activeMonitor
	if (Settings.frameCapSetTo >= 60):
		_frameOptions.selected = 1
	elif (Settings.frameCapSetTo >= 30):
		_frameOptions.selected = 0
	else:
		_frameOptions.selected = 2
	print(Settings.masterVolume)
	_masterVolumeBar.value = lerp(_masterVolumeBar.min_value, _masterVolumeBar.max_value, 
									Settings.masterVolume) 
	_deviceVolumeBar.value = lerp(_deviceVolumeBar.min_value, _deviceVolumeBar.max_value, 
									Settings.deviceVolume)
	_gameVolumeBar.value = lerp(_gameVolumeBar.min_value, _gameVolumeBar.max_value, 
									Settings.gameVolume)


#region Signal Functions
func _onProactivityToggle(toggle: bool):
	Settings.setProactivitySetting(toggle)


func _onSetWindowAttention(index: int):
	Settings.setWindowAttentionMode(index)


func _onWindowOrientationOptions(index : int):
	Settings.setWindowOrientation(index)


func _onMonitorOptions(index : int):
	Settings.monitorSetTo = index
	Settings.changeActiveMonitor(index)


func _onFrameOptions(index : int):
	match index:
		0:
			Settings.setFrameCap(30)
		1:
			Settings.setFrameCap(60)
		2:
			Settings.setFrameCap(0)

func _onMasterVolume(value : float):
	print(value / _masterVolumeBar.max_value)
	Settings.setVolume(SfxManager.BusType.MASTER, value / _masterVolumeBar.max_value)


func _onDeviceVolume(value : float):
	Settings.setVolume(SfxManager.BusType.DEVICE, value / _deviceVolumeBar.max_value)


func _onGameVolume(value : float):
	Settings.setVolume(SfxManager.BusType.GAME, value / _gameVolumeBar.max_value)

#endregion

#region Helper Functions
func _fillMonitorOptions(options : OptionButton, monitorCount : int) -> void:
	for x in range(monitorCount):
		options.add_item("Display " + str(x))
#endregion

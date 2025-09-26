extends Menu
@export_category("Skin Information")
@export var deviceSkin : PaletteSwappableSkin
@export var _previewAddons : Array[Texture2D]
#@export var _skins : Array[Texture2D]
#@export var _colorPalettes : Array[Texture2D]
#@export var _paletteNames : Array[Array]
@export_category("Node References")
@export var _previewDevice : TextureRect
@export var _previewAddonsRect : TextureRect
@export var _paletteName : Label
var _currentIndex : Vector2i

func _loadSavedMenuSettings():
	_currentIndex = Settings.deviceSkin
	_drawDevicePreview()


func _saveMenuSettings():
	Settings.deviceSkin = _currentIndex
	GameEvents.DeviceUpdateSkin.emit()
	super()


func _onChangeSkin(index : int):
	if (index == _currentIndex.x):
		return
	
	_currentIndex = Vector2i(index, 0)
	_drawDevicePreview()


func _onChangePalette(dir : int):
	_currentIndex.y += dir
	
	if (_currentIndex.y < 0):
		_currentIndex.y = deviceSkin.paletteNames[_currentIndex.x].size() - 1
	if (_currentIndex.y >= deviceSkin.paletteNames[_currentIndex.x].size()):
		_currentIndex.y = 0
	
	_drawDevicePreview()


func _drawDevicePreview():
	_previewDevice.texture = deviceSkin.skins[_currentIndex.x]
	_previewDevice.material.palette = deviceSkin.colorPalettes[_currentIndex.x]
	_previewDevice.material.row = _currentIndex.y
	_paletteName.text = deviceSkin.paletteNames[_currentIndex.x][_currentIndex.y]
	_previewAddonsRect.texture = _previewAddons[_currentIndex.x]

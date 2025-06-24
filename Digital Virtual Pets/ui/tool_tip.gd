extends Node

@export_category("Node References")
@export var _textLabel : Label
@export var _window : Window
@export_category("Tooltip Settings")
@export var _defaultWindowSize : Vector2i
@export var _textToDisplay : String
@export var _marginSize : Vector2

func _ready() -> void:
	_updateToolTipText(_textToDisplay)

func _updateToolTipText(text := ""):
	_textLabel.text = text
	await get_tree().process_frame
	await get_tree().process_frame
	print(_textLabel.text)
	print(_textLabel.size)
	if (_textLabel.size.x > _defaultWindowSize.x - (_marginSize.x * 2)):
		_setLabelMode(false)
		_window.size.y = _textLabel.size.y + (_marginSize.y * 2)
		_window.size.x = _defaultWindowSize.x
		
		print(_textLabel.size.x)
	else:
		_setLabelMode(true)
		_window.size.y = _defaultWindowSize.y
		_window.size.x = _textLabel.size.x + (_marginSize.x * 2)
	
	_textLabel.visible = false
	_textLabel.visible = true


func _setLabelMode(isSmallMode : bool):
	if (isSmallMode):
		print("Single Line Mode")
		_textLabel.size.x = 0
		_textLabel.autowrap_mode = TextServer.AUTOWRAP_OFF
	else:
		print("Multi Line Mode")
		_textLabel.size.x = _defaultWindowSize.x - (_marginSize.x * 2)
		_textLabel.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

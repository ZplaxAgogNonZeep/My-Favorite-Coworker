extends Node

class_name ToolTip

@export_category("Node References")
@export var _singleLabel : Label
@export var _overflowLabel : Label
@export var _window : Window
@export var _animator : AnimationPlayer
@export_category("Tooltip Settings")
@export var _animationLibrary : String
@export var _defaultWindowSize : Vector2i
@export var _textToDisplay : String
@export var _marginSize : Vector2

func _ready() -> void:
	GameEvents.CallToolTip.connect(_callToolTip)
	GameEvents.DismissToolTip.connect(_dismissToolTip)
	_window.visible = false


func _callToolTip(screenPosn : Vector2i, text : String):
	if (_window.visible):
		await _dismissToolTip()
	
	_window.position = screenPosn
	_animator.play(_animationLibrary + "/open_noscale")
	await get_tree().process_frame
	await get_tree().process_frame
	_window.visible = true
	_updateToolTipText(text)



func _dismissToolTip():
	_animator.play(_animationLibrary + "/close_noscale")
	await _animator.animation_finished
	_window.visible = false


func _updateToolTipText(text := ""):
	var textToUse : String
	if (text == ""):
		textToUse = _textToDisplay
	else:
		textToUse = text
	_singleLabel.text = textToUse
	_overflowLabel.text = textToUse
	
	await get_tree().process_frame
	
	if (_singleLabel.size.x > _defaultWindowSize.x - (_marginSize.x * 2)):
		# Text Overflows
		_setLabelMode(false)
		_window.size.y = _overflowLabel.size.y + (_marginSize.y * 2)
	else:
		# Single or Multi Line
		_setLabelMode(true)
		if (textToUse.contains("\n")):
			_window.size.y = _singleLabel.size.y + (_marginSize.y * 2)
		else:
			_window.size.y = _defaultWindowSize.y
		_window.size.x = _singleLabel.size.x + (_marginSize.x * 2)



func _setLabelMode(isSmallMode : bool):
	if (isSmallMode):
		_singleLabel.visible = true
		_overflowLabel.visible = false
	else:
		_singleLabel.visible = false
		_overflowLabel.visible = true

extends Panel

signal DialogChoiceSelected(choiceIndex : int, threadIndex : int, window : Control)

@export_category("Node References")
@export var _windowContainer : Window
@export var _dialogLabel : RichTextLabel
@export var _characterNameLabel : Label
@export var _choiceContainer : HBoxContainer
@export var _animator : AnimationPlayer
@export var _closeButton : Button
@export var _buttonScene : PackedScene
@export var _colorKeywords : Dictionary[String, Color] = {"BLUE" : Color("#97D6FF"),
															"CREAM" : Color("#EBE9D5"),
															"GREEN" : Color("#D0E1A3"),
															"YELLOW" : Color("#FFF0AD"),
															"PURPLE" : Color("#D2B5E3"),
															"RED" : Color("#FF0000")}

var _baseLabelSize : float
var _positionOffset : Vector2
var _threadIndex : int
var _givenPosition

func _ready() -> void:
	get_parent()
	visible = false
	_animator.play("Open")
	await get_tree().process_frame
	visible = true
	if (_baseLabelSize < _dialogLabel.size.y):
		var diff = _dialogLabel.size.y - _baseLabelSize
		size.y += diff
		await get_tree().process_frame
	_windowContainer.setWindowToCanvasSize()
	if (_givenPosition == Vector2i(-999, -999)):
		_windowContainer.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	else:
		_windowContainer.position = Settings.findValidWindowPosition(Settings.SubWindowPositionType.DIALOG, 
																	_windowContainer.size, _givenPosition)


func loadWindow(pos : Vector2i, text : String, speaker : String, links : Array[String], threadIndex : int):
	_threadIndex = threadIndex
	_positionOffset = position
	_baseLabelSize = _dialogLabel.size.y
	_givenPosition = pos
	#if (Settings.getMonitorResolution().size.x > 2000 or Settings.getMonitorResolution().size.y > 1200):
		#_dialogLabel.theme_type_variation = "BigParagraphText"
	
	# Set the Window Position, if the position is set to specifically (-1, -1), it will default to
	# the center of the primary monitor
	#if (pos == Vector2i(-999, -999)):
		#_windowContainer.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	#else:
		#_windowContainer.position = Settings.findValidWindowPosition(Settings.SubWindowPositionType.DIALOG, 
																	#_windowContainer.size, pos)
	if (_givenPosition == Vector2i(-999, -999)):
		_windowContainer.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	_windowContainer.title = speaker
	_characterNameLabel.text = speaker
	
	# Filter for color keywords
	
	for keyword in _colorKeywords.keys():
		if text.contains("#" + keyword):
			text = text.replace("#" + keyword, "#" + _colorKeywords[keyword].to_html(false))
	
	_dialogLabel.text = text
	
	if (links.size() <= 0):
		_closeButton.disabled = false
		var button = _buttonScene.instantiate()
		button.text = "Finish"
		button.ChoiceButtonPressed.connect(_buttonSelected)
		_choiceContainer.call_deferred("add_child", button)
	else:
		_closeButton.disabled = true
		var count = 0
		for link in links:
			var button = _buttonScene.instantiate()
			button.text = link
			button.ChoiceButtonPressed.connect(_buttonSelected)
			button.index = count
			_choiceContainer.call_deferred("add_child", button)
			count += 1


func setWindowPosition():
	pass


func _buttonSelected(index : int):
	DialogChoiceSelected.emit(index, _threadIndex, self)
	print(index)


func changeThreadIndex(index : int):
	_threadIndex = index


func closeWindow():
	_animator.play("Close")
	await _animator.animation_finished
	_windowContainer.queue_free()

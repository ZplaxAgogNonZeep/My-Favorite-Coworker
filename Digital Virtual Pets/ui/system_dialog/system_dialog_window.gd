extends Panel

signal DialogChoiceSelected(choiceIndex : int, threadIndex : int, window : Control)

@export_category("Node References")
@export var _windowContainer : Window
@export var _dialogLabel : Label
@export var _characterNameLabel : Label
@export var _choiceContainer : HBoxContainer
@export var _animator : AnimationPlayer
@export var _closeButton : Button
@export var _buttonScene : PackedScene

var _baseLabelSize : float
var _positionOffset : Vector2
var _threadIndex : int

func _ready() -> void:
	get_parent()
	_animator.play("Open")
	await get_tree().process_frame
	
	if (_baseLabelSize < _dialogLabel.size.y):
		var diff = _dialogLabel.size.y - _baseLabelSize
		size.y += diff
		_windowContainer.setWindowToCanvasSize()


func loadWindow(pos : Vector2i, text : String, speaker : String, links : Array[String], threadIndex : int):
	_threadIndex = threadIndex
	_positionOffset = position
	_baseLabelSize = _dialogLabel.size.y
	# Set the Window Position, if the position is set to specifically (-1, -1), it will default to
	# the center of the primary monitor
	if (pos == Vector2i(-1, -1)):
		_windowContainer.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	else:
		Settings.findValidWindowPosition(Settings.SubWindowPositionType.DIALOG, _windowContainer.size) + pos
	_windowContainer.title = speaker
	_characterNameLabel.text = speaker
	_dialogLabel.text = text
	
	if (links.size() <= 0):
		_closeButton.disabled = false
	else:
		_closeButton.disabled = true
		for link in links:
			var button = _buttonScene.instantiate()
			button.text = link
			button.ChoiceButtonPressed.connect(_buttonSelected)
			_choiceContainer.call_deferred("add_child", button)


func setWindowPosition():
	pass


func _buttonSelected(index : int):
	DialogChoiceSelected.emit(index, _threadIndex, self)


func changeThreadIndex(index : int):
	_threadIndex = index


func closeWindow():
	_animator.play("Close")
	await _animator.animation_finished
	_windowContainer.queue_free()

extends Panel

signal DialogChoiceSelected(index : int)

@export_category("Node References")
@export var _dialogLabel : Label
@export var _characterNameLabel : Label
@export var _choiceContainer : HBoxContainer
@export var _buttonScene : PackedScene

var _baseLabelSize : float
var _positionOffset : Vector2

func _ready() -> void:
	await get_tree().process_frame
	
	if (_baseLabelSize < _dialogLabel.size.y):
		var diff = _dialogLabel.size.y - _baseLabelSize
		size.y += diff


func loadWindow(pos : Vector2, text : String, speaker : String, links : Array[String]):
	_positionOffset = position
	_baseLabelSize = _dialogLabel.size.y
	position = pos + _positionOffset
	
	_characterNameLabel.text = speaker
	_dialogLabel.text = text
	
	for link in links:
		var button = _buttonScene.instantiate()
		button.text = link
		button.ChoiceButtonPressed.connect(_buttonSelected)
		_choiceContainer.call_deferred("add_child", button)


func _buttonSelected(index : int):
	DialogChoiceSelected.emit(index)

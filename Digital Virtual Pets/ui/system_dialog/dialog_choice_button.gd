extends Button

signal ChoiceButtonPressed(index : int)

var index : int

func _onPressed() -> void:
	ChoiceButtonPressed.emit(index)

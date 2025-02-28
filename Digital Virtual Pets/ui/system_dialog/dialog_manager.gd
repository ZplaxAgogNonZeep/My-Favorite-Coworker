extends Control

class_name DialogSystem

func _ready() -> void:
	GameEvents.DisplayDialog.connect(_callSystemDialog)


func _callSystemDialog():
	pass
	

extends Control

class_name DialogSystem

@export var _systemWindowScene : PackedScene

func _ready() -> void:
	GameEvents.DisplayDialog.connect(_callSystemDialog)


func _callSystemDialog():
	var newDialog = _systemWindowScene.instantiate()
	newDialog.loadWindow(Vector2(256, 320), "AHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH")
	
	call_deferred("add_child", newDialog)

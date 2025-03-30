extends Node

class_name Lifespan

var _lifespan := 0.0
var _paused := false

func _process(delta: float) -> void:
	if (!_paused):
		_lifespan += delta


func getLifespan() -> float:
	return _lifespan


func setLifespan(time : float):
	_lifespan = time

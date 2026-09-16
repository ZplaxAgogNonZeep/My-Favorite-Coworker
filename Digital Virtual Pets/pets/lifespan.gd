extends Node

class_name Lifespan

var _lifespan : int = 0
var _secondsTimer := 0.0
var _paused := false

static func convertLifespanToAge(lifespan : float) -> Array:
	var rawAge = lifespan
	var formattedAge = [0,0,0]
	
	if (rawAge > 1440):
		# Days
		var convertedAge = rawAge / 1440
		formattedAge[0] = floori(convertedAge)
		rawAge -= (formattedAge[0] * 1440)
	if (rawAge > 60):
		# Hours
		var convertedAge = rawAge / 60
		formattedAge[1] = floori(convertedAge)
		rawAge -= (formattedAge[1] * 60)
	if (rawAge > 0):
		# Minutes
		var convertedAge = rawAge
		formattedAge[2] = floori(convertedAge)
	
	return formattedAge

func _process(delta: float) -> void:
	if (!_paused):
		if (_secondsTimer <= 60):
			_secondsTimer += delta
		else:
			_secondsTimer = 0
			_lifespan += 1


func getLifespan() -> float:
	return _lifespan


func setLifespan(time : float):
	_lifespan = time

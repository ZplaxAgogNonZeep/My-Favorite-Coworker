extends Node

class_name Lifespan

var _lifespan : int = 0
var _secondsTimer := 0.0
var _paused := false

static func convertLifespanToAge(lifespan : float) -> Array:
	var rawAge = lifespan
	var formattedAge = [0,0,0]
	
	if (rawAge > 1440):
		# age is bigger than one day
		var convertedAge = rawAge / 1440
		formattedAge[0] = floori(convertedAge)
		formattedAge[1] = rawAge - (1440 * formattedAge[0])
	if (rawAge > 60):
		# age is bigger than one hour
		if (formattedAge[0] > 0 and formattedAge[1] > 60):
			var convertedAge = formattedAge[1] / 60
			formattedAge[2] = formattedAge[1] - (60 * floori(convertedAge))
			formattedAge[1] = floori(convertedAge)
		elif (formattedAge[0] > 0 ):
			formattedAge[2] = formattedAge[1]
			formattedAge[1] = 0
		else:
			var convertedAge = rawAge / 60
			formattedAge[1] = floori(convertedAge)
			formattedAge[2] = formattedAge[1] - (60 * formattedAge[1])
	if (rawAge > 0):
		# age is bigger than one minute
		if (formattedAge[2] > 0):
			var convertedAge = formattedAge[2]
			formattedAge[2] = floori(convertedAge)
		else:
			var convertedAge = rawAge
			formattedAge[2] = floorf(convertedAge)
	
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

extends Node

class_name Lifespan

var _lifespan := 0.0
var _paused := false

static func convertLifespanToAge(lifespan : float) -> Array:
	var rawAge = lifespan
	var formattedAge = [0,0,0]
	
	if (rawAge > 86400):
		# age is bigger than one day
		var convertedAge = rawAge / 86400
		formattedAge[0] = floorf(convertedAge)
		formattedAge[1] = rawAge - (86400 * formattedAge[0])
	if (rawAge > 3600):
		# age is bigger than one hour
		if (formattedAge[0] > 0 and formattedAge[1] > 3600):
			var convertedAge = formattedAge[1] / 3600
			formattedAge[2] = formattedAge[1] - (3600 * floorf(convertedAge))
			formattedAge[1] = floorf(convertedAge)
		elif (formattedAge[0] > 0 ):
			formattedAge[2] = formattedAge[1]
			formattedAge[1] = 0
		else:
			var convertedAge = rawAge / 3600
			formattedAge[1] = floorf(convertedAge)
			formattedAge[2] = formattedAge[1] - (3600 * formattedAge[1])
	if (rawAge > 60):
		# age is bigger than one minute
		if (formattedAge[2] > 0):
			var convertedAge = formattedAge[2] / 60
			formattedAge[2] = floorf(convertedAge)
		else:
			var convertedAge = rawAge / 60
			formattedAge[2] = floorf(convertedAge)
	
	return formattedAge

func _process(delta: float) -> void:
	if (!_paused):
		_lifespan += delta


func getLifespan() -> float:
	return _lifespan


func setLifespan(time : float):
	_lifespan = time

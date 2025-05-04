extends Node2D

var implements = []

@export var _indicatorMeter : Meter
@export var _rightGoalMeter : Meter
@export var _leftGoalMeter : Meter

var _value : int
var _valueSectionSize : int
var _maxValue : int
var _goalValue : int
var _goalMaxValue : int
var _activeTween : Tween

## Sets up the mash meter with a maximum value and a set of goals.
func initializeMeter(maxValue : int, goal : int, goalMax : int = 0, valueSectionSize : int = 1):
	_value = 0
	_maxValue = maxValue
	_valueSectionSize = valueSectionSize
	_indicatorMeter.setSectionValue(0, valueSectionSize, maxValue)
	setGoal(goal, goalMax)


## Sets the goal for the mash meter using the given [param goal] and the [param goalMax] as the visible
## sections of the Meter.
func setGoal(goal : int, goalMax : int = 0):
	_goalValue = goal
	_goalMaxValue = goalMax
	
	_rightGoalMeter.setSectionValue(goal, goalMax, _maxValue)


## Adds the given [param incrementAmount] to the mash meter's value, then updates the indicator meter 
## to match.
func addToValue(incrementAmount : int):
	_value += incrementAmount
	
	if (_value + _valueSectionSize > _maxValue):
		_value = _maxValue - _valueSectionSize
	if (_value < 0):
		_value = 0
	_indicatorMeter.setSectionValue(_value, _value + _valueSectionSize, _maxValue)
	


## Returns a bool representing whether or not the the sections value is within the goal
func isWithinGoal() -> bool:
	return ((_value >= _goalValue or _value + _valueSectionSize >= _goalValue) 
		and (_value <= _goalMaxValue or _value + _valueSectionSize <= _goalMaxValue))


#func updateMeter(value : int, max : int):
	#self.value = value
	#var percentage =  float(value) / float(max)
	#var finalPosition = lerp($Min.position, $Max.position, percentage)
	#$MeterIndicator.position = finalPosition
	#if (_activeTween):
		#_activeTween.stop()
		#_activeTween = null
	#_activeTween = create_tween()
	#_activeTween.tween_property($MeterIndicator, "position", finalPosition, .1)

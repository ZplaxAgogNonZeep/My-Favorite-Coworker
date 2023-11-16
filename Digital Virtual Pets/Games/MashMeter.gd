extends Node2D

var implements = []

@onready var offset = abs($Max.position.x - $GoalIndicator/LeftIndicator.position.x)

var value : int
var maxValue : int
var goalValue : int
var goalMaxValue : int
var activeTween : Tween

func initializeMeter(max : int, goal : int, goalMax : int = 0):
	value = 0
	maxValue = max
	setGoal(goal, goalMax)

func setGoal(goal : int, goalMax : int = 0):
	goalValue = goal
	goalMaxValue - goalMax
	
	if goalMax > goal:
		var minGoalPercent = float(goal) / float(maxValue)
		var maxGoalPercent = float(goalMax) / float (maxValue)
		var minGoalPosn = lerp($Min.position, $Max.position, minGoalPercent)
		var maxGoalPosn = lerp($Min.position, $Max.position, maxGoalPercent)
		var stretchAmount = minGoalPosn.distance_to(maxGoalPosn)
		$GoalIndicator/LeftIndicator.position.y = maxGoalPosn.y
		$GoalIndicator/RightIndicator.position.y = maxGoalPosn.y
		$GoalIndicator/LeftIndicator.scale.y = stretchAmount
		$GoalIndicator/RightIndicator.scale.y = stretchAmount
	else:
		var percentage = float(goal) / float(maxValue)
		var finalPosition = lerp($Min.position, $Max.position, percentage)
		$Goal.position = finalPosition
		var stretchAmount = finalPosition.distance_to($Max.position + Vector2(0, -5))
		$GoalIndicator/LeftIndicator.scale.y = stretchAmount
		$GoalIndicator/RightIndicator.scale.y = stretchAmount
	
	

func updateMeter(value : int, max : int):
	self.value = value
	var percentage =  float(value) / float(max)
	var finalPosition = lerp($Min.position, $Max.position, percentage)
	print(value, " / ", max)
	$MeterIndicator.position = finalPosition
	if (activeTween):
		activeTween.stop()
		activeTween = null
	activeTween = create_tween()
	activeTween.tween_property($MeterIndicator, "position", finalPosition, .1)

extends Node2D

var implements = []

@onready var offset = abs($GoalIndicator/LeftIndicator.position.x - position.x)

var value : int
var maxValue : int
var goalValue : int


func initializeMeter(max : int, goal : int):
	value = 0
	maxValue = max
	setGoal(goal)

func setGoal(goal : int):
	goalValue = goal
	var percentage = goal / maxValue
	var finalPosition = lerp($Min.position, $Max.position, percentage)
	var stretchAmount = finalPosition.distance_to(Vector2($GoalIndicator/LeftIndicator.position.x - offset, $GoalIndicator/LeftIndicator.position.y))
	$GoalIndicator/LeftIndicator.scale.y = stretchAmount
	$GoalIndicator/RightIndicator.scale.y = stretchAmount

func updateMeter(value : int, max : int):
	self.value = value
	var percentage = value / max
	var finalPosition = lerp($Min.position, $Max.position, percentage)
	create_tween().tween_property($MeterIndicator, "position", finalPosition, .1)

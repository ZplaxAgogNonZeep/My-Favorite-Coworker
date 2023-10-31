extends Node

var implements = [Interface.PetType]

var waitIntervalMax := 10.0
var waitIntervalMin := 3.0

var petName := "BuhBuh"

@export var tempEvolveCondition = true

func roamBehavior():
	if not get_parent().isRoaming and $MoveTimer.is_stopped():
		randomize()
		$MoveTimer.start(randf_range(waitIntervalMin, waitIntervalMax))

func feedingBehavior():
	pass

func onTickHunger():
	pass

func onTickJoy():
	pass

func onEatFood():
	pass

func getEvolvePet():
	return null

func _on_move_timer_timeout():
	get_parent().goToPosition(get_parent().getNextPosition())

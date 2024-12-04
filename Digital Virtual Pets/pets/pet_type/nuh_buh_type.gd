extends Node

var implements = [Interface.PetType]

@export var tempEvolveCondition := false

var waitIntervalMax := 10.0
var waitIntervalMin := 3.0

var petName := "NuhBuh"

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
	if tempEvolveCondition:
		return get_parent().evolvesTo[0]
	if get_parent().abilityStats[Enums.AbilityStat.BAL] > 7 and get_parent().abilityStats[Enums.AbilityStat.SPD] > 2:
		return get_parent().evolvesTo[0]
	else:
		return null

func _on_move_timer_timeout():
	get_parent().goToPosition(get_parent().getNextPosition())

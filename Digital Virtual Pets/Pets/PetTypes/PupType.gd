extends Node

var implements = [Interface.PetType]


var waitIntervalMax := 10.0
var waitIntervalMin := 3.0

var petName := "Buh"

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
	if get_parent().abilityStats[Enums.AbilityStat.END] > 5:# or tempEvolveCondition:
		return get_parent().evolvesTo[0]
	elif (get_parent().traumaCount >= 1 and get_parent().abilityStats[Enums.AbilityStat.SPD] > 5) or tempEvolveCondition:
		return get_parent().evolvesTo[1]
	else:
		return null

func _on_move_timer_timeout():
	get_parent().goToPosition(get_parent().getNextPosition())

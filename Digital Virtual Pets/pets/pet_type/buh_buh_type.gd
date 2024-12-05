extends PetType


func getEvolvePet() -> Pet:
	if tempEvolveCondition:
		return get_parent().evolvesTo[0]
	if get_parent().abilityStats[Enums.AbilityStat.BAL] > 7 and get_parent().abilityStats[Enums.AbilityStat.SPD] > 2:
		return get_parent().evolvesTo[0]
	else:
		return null

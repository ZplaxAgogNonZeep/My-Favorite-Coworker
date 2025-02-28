extends PetType

func getEvolvePet():
	if tempEvolveCondition:
		return pet.evolvesTo[0]
	if pet.abilityStats[Enums.AbilityStat.END] > 2 or pet.abilityStats[Enums.AbilityStat.SPD] > 2:
		return pet.evolvesTo[0]
	elif (pet.traumaCount >= 1):
		return pet.evolvesTo[1]
	else:
		return null



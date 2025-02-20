extends Resource

class_name PetTypeData

@export_category("Pet Type Data")
@export var name : String
@export var spriteFrames : SpriteFrames

@export_category("Behavior Variables")
@export var waitIntervals : Vector2

@export_category("Evolution Data")
@export var evolutions : Array[Resource]
@export var evolutionCondition : Dictionary = { # Transfered
	"POW": -1, 
	"END": -1,
	"SPD": -1,
	"BAL": -1,
	"TraumaGreater" : -1,
	"TraumaLesser" : -1,
	"TraumaEqual" : -1,
	"Personality" : -1
	}

func getNextEvolution(pet : Pet) -> Resource:
	for evolution : PetTypeData in evolutions:
		if (evolutionCondition["POW"] > -1):
			if (pet.abilityStats[Enums.AbilityStat.POW] < evolutionCondition["POW"]):
				continue
		if (evolutionCondition["END"] > -1):
			if (pet.abilityStats[Enums.AbilityStat.END] < evolutionCondition["END"]):
				continue
		if (evolutionCondition["SPD"] > -1):
			if (pet.abilityStats[Enums.AbilityStat.SPD] < evolutionCondition["SPD"]):
				continue
		if (evolutionCondition["BAL"] > -1):
			if (pet.abilityStats[Enums.AbilityStat.BAL] < evolutionCondition["BAL"]):
				continue
		if (evolutionCondition["TraumaGreater"] > -1):
			if (pet.traumaCount < evolutionCondition["TraumaGreater"]):
				continue
		if (evolutionCondition["TraumaLesser"] > -1):
			if (pet.traumaCount > evolutionCondition["TraumaLesser"]):
				continue
		if (evolutionCondition["TraumaEqual"] > -1):
			if (pet.traumaCount != evolutionCondition["TraumaEqual"]):
				continue
		if (evolutionCondition["Personality"] > -1):
			if (pet.traumaCount != evolutionCondition["Personality"]):
				continue
		
		return evolution
		
	return null

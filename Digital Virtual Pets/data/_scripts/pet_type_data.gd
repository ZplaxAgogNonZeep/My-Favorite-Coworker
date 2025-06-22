extends Resource

class_name PetTypeData

const SPRITE_OFFSETS : Array[float] = [-8, -8, -10, -12]
const COLLISION_OFFSETS : Array[float] = [0, 4, 10, 12]

@export_category("Pet Type Data")
@export var name : String
@export var spriteFrames : SpriteFrames

@export_category("Sound Effects")
@export var yap : SoundGroup

@export_category("Behavior Variables")
@export var stage : int
@export var waitIntervals : Vector2 = Vector2(3, 10)

@export_category("Evolution Data")
@export var evolutions : Array[Resource]
@export var statConditionOr = false
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
@export_category("Bio Info")
@export var encyclopediaEntry : String


func getNextEvolution(pet : Pet) -> Resource:
	for evolution : PetTypeData in evolutions:
		print("Checking ", evolution.name)
		var statConditionMet = false
		if (evolutionCondition["POW"] > -1):
			if (pet.abilityStats[Enums.AbilityStat.POW] < evolutionCondition["POW"]):
				if (!statConditionOr):
					continue
			else:
				statConditionMet = true
		if (evolutionCondition["END"] > -1):
			if (pet.abilityStats[Enums.AbilityStat.END] < evolutionCondition["END"]):
				if (!statConditionOr):
					continue
			else:
				statConditionMet = true
		if (evolutionCondition["SPD"] > -1):
			if (pet.abilityStats[Enums.AbilityStat.SPD] < evolutionCondition["SPD"]):
				if (!statConditionOr):
					continue
			else:
				statConditionMet = true
		if (evolutionCondition["BAL"] > -1):
			if (pet.abilityStats[Enums.AbilityStat.BAL] < evolutionCondition["BAL"]):
				if (!statConditionOr):
					continue
			else:
				statConditionMet = true
		
		if (!statConditionMet && statConditionOr):
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

func getSpriteIcon() -> Texture2D:
	return spriteFrames.get_frame_texture("Idle", 0)


func getSpriteOffset() -> float:
	return SPRITE_OFFSETS[stage]


func getCollisionOffset() -> float:
	return COLLISION_OFFSETS[stage]

func _to_string() -> String:
	return name

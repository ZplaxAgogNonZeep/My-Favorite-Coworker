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
@export var evolutionConditions : Array[EvolutionCondition]

@export_category("Bio Info")
@export var encyclopediaEntry : String


func getNextEvolution(pet : Pet) -> Resource:
	for evolution : PetTypeData in evolutions:
		if (evolution.checkEvolutionConditions(pet)):
			return evolution
		
	return null


func checkEvolutionConditions(pet : Pet) -> bool:
	var andConditionMet = true
	var orConditionMet = true
	var orResults = []
	var andResults = []
	for condition : EvolutionCondition in evolutionConditions:
		match condition.conditionLogic:
			EvolutionCondition.LogicalConditionals.AND:
				orResults.append(condition.checkConditionMet(pet))
			EvolutionCondition.LogicalConditionals.OR:
				andResults.append(condition.checkConditionMet(pet))
	
	if (orResults.size() > 0):
		if (!orResults.has(true)):
			orConditionMet = false
	
	if (andResults.size() > 0):
		if (andResults.has(false)):
			andConditionMet = false
	
	return andConditionMet and orConditionMet


func getSpriteIcon() -> Texture2D:
	return spriteFrames.get_frame_texture("Idle", 0)


func getSpriteOffset() -> float:
	return SPRITE_OFFSETS[stage]


func getCollisionOffset() -> float:
	return COLLISION_OFFSETS[stage]


func getAllPossibleEvolutions() -> Array[PetTypeData]:
	var unsortArray =  _r_getAllPossibleEvolutions()
	var returnArray : Array[PetTypeData] = []
	
	for evolution in unsortArray:
		if !returnArray.has(evolution):
			returnArray.append(evolution)
	
	return returnArray


func _r_getAllPossibleEvolutions() -> Array[PetTypeData]:
	var returnArray : Array[PetTypeData] = []
	returnArray.append(self)
	for evolution in evolutions:
		returnArray.append_array(evolution._r_getAllPossibleEvolutions())
	return returnArray


func _to_string() -> String:
	return name


func getFormattedEvolutionConditions() -> String:
	var returnString : String
	for condition : EvolutionCondition in evolutionConditions:
			if returnString != "":
				match condition.conditionLogic:
					EvolutionCondition.LogicalConditionals.OR:
						returnString += "Or\n"
					EvolutionCondition.LogicalConditionals.AND:
						returnString += "And\n"
			
			if (PetManager.instance != null):
				returnString += condition.toFormattedString(PetManager.instance.getStatRecord(self), PetManager.instance.getStatusRecord(self)) + "\n"
			else:
				returnString += str(condition) + "\n"
	
	if (returnString.contains("\n")):
		returnString = returnString.erase(returnString.rfind("\n"))
	
	if returnString == "":
		returnString = "No Evolution Conditions"
	return returnString

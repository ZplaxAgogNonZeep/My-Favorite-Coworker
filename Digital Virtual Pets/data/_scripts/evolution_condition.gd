extends Resource
class_name EvolutionCondition
enum LogicalConditionals {OR, AND}
enum StatusCondition {OVERFED, OVERSTIMULTED, HUNGRY, BORED, STINKY, ANXIOUS, NONE, ANY}
@export var conditionLogic : LogicalConditionals
@export_category("Conditions")
@export var POW := -1
@export var END := -1
@export var SPD := -1
@export var BAL := -1
@export var TraumaGreater := -1
@export var TraumaLesser := -1
@export var TraumaEqual := -1
@export var Personality := -1
@export var statTotal := -1
@export var conditions : Array[StatusCondition]

func checkConditionMet(pet : Pet) -> bool:
	if (POW > -1):
		if (pet.abilityStats[Enums.AbilityStat.POW] >= POW):
			pass
		else:
			return false
	if (END > -1):
		if (pet.abilityStats[Enums.AbilityStat.END] >= END):
			pass
		else:
			return false
	if (SPD > -1):
		if (pet.abilityStats[Enums.AbilityStat.SPD] >= SPD):
			pass
		else:
			return false
	if (BAL > -1):
		if (pet.abilityStats[Enums.AbilityStat.BAL] >= BAL):
			pass
		else:
			return false
	
	if (statTotal > -1):
		if (pet.getStatTotal() < statTotal):
			return false
	
	if (TraumaGreater > -1):
		if (pet.traumaCount <= TraumaGreater):
			return false
	if (TraumaLesser > -1):
		if (pet.traumaCount >= TraumaLesser):
			return false
	if (TraumaEqual > -1):
		if (pet.traumaCount != TraumaEqual):
			return false
	if (Personality > -1):
		if (pet.traumaCount != Personality):
			return false
	
	for statusCondition in conditions:
		if statusCondition == StatusCondition.ANY:
			if (!pet.checkAnyStatus()):
				return false
		elif statusCondition == StatusCondition.NONE:
			if (pet.checkAnyStatus()):
				return false
		elif (!pet.checkStatus(int(statusCondition))):
			return false
	
	return true

func _to_string() -> String:
	var returnString : String
	if POW > -1:
		returnString += "POW: " + str(POW) + "\n"
	if END > -1:
		returnString += "END: " + str(END) + "\n"
	if SPD > -1:
		returnString += "SPD: " + str(SPD) + "\n"
	if BAL > -1:
		returnString += "BAL: " + str(BAL) + "\n"
	
	if (statTotal > -1):
		returnString += "Stat Total: " + str(statTotal) + "\n"
	
	if TraumaGreater > -1:
		returnString += "Trauma greater than " + str(TraumaGreater) + "\n"
	if TraumaLesser > -1:
		returnString += "Trauma less than " + str(TraumaLesser) + "\n"
	if TraumaEqual > -1:
		returnString += "Trauma equal to " + str(TraumaEqual) + "\n"
	
	returnString = returnString.erase(returnString.rfind("\n"))
	
	return returnString

func toFormattedString(statRecord : Array) -> String:
	var returnString : String
	if POW > -1:
		if (statRecord[0] < POW):
			returnString += "???: ???\n"
		else:
			returnString += "POW: " + str(POW) + "\n"
	if END > -1:
		if (statRecord[1] < END):
			returnString += "???: ???\n"
		else:
			returnString += "END: " + str(END) + "\n"
	if SPD > -1:
		if (statRecord[2] < SPD):
			returnString += "???: ???\n"
		else:
			returnString += "SPD: " + str(SPD) + "\n"
	if BAL > -1:
		if (statRecord[3] < BAL):
			returnString += "???: ???\n"
		else:
			returnString += "BAL: " + str(BAL) + "\n"
	
	if (statTotal > -1):
		if (statRecord[5] < statTotal):
			returnString += "???: ???\n"
		else:
			returnString += "Stat Total: " + str(statTotal) + "\n"
	
	if TraumaGreater > -1:
		if (statRecord[4] < TraumaGreater):
			returnString += "Trauma: ???\n"
		else:
			returnString += "Trauma greater than " + str(TraumaGreater) + "\n"
	if TraumaLesser > -1:
		returnString += "Trauma less than " + str(TraumaLesser) + "\n"
	if TraumaEqual > -1:
		if (statRecord[4] < TraumaEqual):
			returnString += "Trauma: ???\n"
		else:
			returnString += "Trauma equal to " + str(TraumaEqual) + "\n"
	
	for condition in conditions:
		pass
	
	returnString = returnString.erase(returnString.rfind("\n"))
	
	return returnString

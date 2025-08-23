@tool
extends Node

@export_tool_button("Import Pet Data")
var x: Callable = _fillPetData
@export var _rootFilepath : String
@export var _petDataFilePathRoot : String
@export var _placeholderSpriteFrames : SpriteFrames


func _fillPetData():
	var file = FileAccess.open(_rootFilepath, FileAccess.READ)
	var lines = file.get_as_text().replace("\r", "").split("\n")
	for line in lines:
		var petDataList : PackedStringArray = line.split("\t")
		var petData = _getResourceFromName(petDataList[0], petDataList[1])
		if petData == null:
			petData = PetTypeData.new()
			petData.spriteFrames = _placeholderSpriteFrames
		petData.name = petDataList[0]
		print("Updateing ", petData.name)
		petData.stage = int(petDataList[1])
		petData.encyclopediaEntry = petDataList[2]
		petData.evolutionConditions.clear()
		#TODO: 3 = Evolutions DO THIS LATER
		# Okay so indexes 4-13 is for evolution conditions, in that, there's some extra formatting
		# that needs to be done to enter that: [condition group number]-AND/OR+Stat Value
		# to parse this, I'm going to create a dict of arrays that will contain lines to be parsed
		# each group representing one condition with the first element being the "default" one
		var groups : Dictionary[String, Array]
		groups[""] = []
		
		var count = 4
		while count <= 9:
			if (petDataList[count] == "" or petDataList[count] == "N/A"):
				count += 1
				continue
			
			var statString
			match count:
				4:
					statString = "POW|"
				5:
					statString = "END|"
				6:
					statString = "SPD|"
				7:
					statString = "BAL|"
				8:
					statString = "STATTOTAL|"
				9:
					statString = "TRAUMA|"
				10:
					statString = "CONDITION1|"
				11:
					statString = "CONDITION2|"
				12:
					statString = "CONDITION3|"
				13:
					statString = "CONDITION4|"
					
			if petDataList[count].contains("+"):
				if groups.has(petDataList[count].split("+")[0]):
					groups[petDataList[count].split("+")[0]].append(statString + petDataList[count].split("+")[1])
				else:
					groups[petDataList[count].split("+")[0]] = [statString + petDataList[count].split("+")[1]]
			else:
				groups[""].append(statString + petDataList[count])
			
			count += 1
		
		var andConditions = []
		for groupKey in groups.keys():
			if (groups[groupKey].size() == 0):
				continue
				
			var condition = EvolutionCondition.new()
			
			if groupKey == "":
				condition.conditionLogic = EvolutionCondition.LogicalConditionals.AND
			else:
				match groupKey.split("-")[1]:
					"AND":
						condition.conditionLogic = EvolutionCondition.LogicalConditionals.AND
					"OR":
						condition.conditionLogic = EvolutionCondition.LogicalConditionals.OR
			
			for stat : String in groups[groupKey]:
				match stat.split("|")[0]:
					"POW":
						condition.POW = int(stat.split("|")[1])
					"END":
						condition.END = int(stat.split("|")[1])
					"SPD":
						condition.SPD = int(stat.split("|")[1])
					"BAL":
						condition.BAL = int(stat.split("|")[1])
					"STATTOTAL":
						condition.statTotal = int(stat.split("|")[1])
					"TRAUMA":
						match stat.split("|")[1][0]:
							'>':
								condition.TraumaGreater = stat.split("|")[1].substr(1)
							'<':
								condition.TraumaLesser = stat.split("|")[1].substr(1)
							'=':
								condition.TraumaEqual = stat.split("|")[1].substr(1)
					"CONDITION1":
						match stat.split("|")[1].to_upper():
							"NONE":
								condition.conditions.append(EvolutionCondition.StatusCondition.NONE)
							"ANY CONDITION":
								condition.conditions.append(EvolutionCondition.StatusCondition.ANY)
							"OVERFED":
								condition.conditions.append(EvolutionCondition.StatusCondition.OVERFED)
							"OVERSTIMULATED":
								condition.conditions.append(EvolutionCondition.StatusCondition.OVERSTIMULTED)
							"HUNGRY":
								condition.conditions.append(EvolutionCondition.StatusCondition.HUNGRY)
							"BORED":
								condition.conditions.append(EvolutionCondition.StatusCondition.BORED)
							"STINKY":
								condition.conditions.append(EvolutionCondition.StatusCondition.STINKY)
							"ANXIOUS":
								condition.conditions.append(EvolutionCondition.StatusCondition.ANXIOUS)
							_:
								print("PARSE ERROR: Could not parse Status Condition: ", stat.split("|")[1].to_upper())
			
			if (condition.conditionLogic == EvolutionCondition.LogicalConditionals.AND):
				andConditions.append(condition)
			else:
				petData.evolutionConditions.append(condition)
		
		for condition in andConditions:
			petData.evolutionConditions.append(condition)
	
	# Now finally we do evolutions now that we've ensured that all pets from list
	# have been added
	for line in lines:
		var petDataList : PackedStringArray = line.split("\t")
		var petData = _getResourceFromName(petDataList[0], petDataList[1])
		petData.evolutions.clear()
		
		if petDataList[3] != "":
			for evolutionName in petDataList[3].split(","):
				petData.evolutions.append(_getResourceFromName(evolutionName, str(petData.stage + 1)))
	
	print("Pet Data Import Complete")


func _getResourceFromName(petName : String, stage : String) -> PetTypeData:
	var fileNames = DirAccess.get_files_at(_petDataFilePathRoot + "stage_" + stage)
	
	for fileName in fileNames:
		var resource = load(_petDataFilePathRoot + "stage_" + stage + "/" + fileName)
		if resource.name == petName:
			return resource
	
	return null

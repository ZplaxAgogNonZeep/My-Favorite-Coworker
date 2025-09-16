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
		if (line == ""):
			continue
		var petDataList : PackedStringArray = line.split("\t")
		var petData = _getResourceFromName(petDataList[0], petDataList[1])
		var writeToFile = false
		if petData == null:
			writeToFile = true
			print("Found no matching data for ", petDataList[0])
			petData = PetTypeData.new()
			petData.spriteFrames = _placeholderSpriteFrames
			petData.name = petDataList[0]
			petData.stage = int(petDataList[1])
			ResourceSaver.save(petData, _petDataFilePathRoot + "stage_" + petDataList[1] + "/" + petDataList[0].to_lower() + ".tres")
			petData = _getResourceFromName(petDataList[0], petDataList[1])
		
		petData.name = petDataList[0]
		petData.stage = int(petDataList[1])
		petData.encyclopediaEntry = petDataList[2]
		print("Updateing ", petData.name,"-" , petData.stage,"=====================================")
		
		# This whole next part is entirely built around setting up evolution conditions,
		# we'll do this section twice in order to account for parallel evolutions.
		#region Normal Evo Conditions
		# Okay so indexes 4-13 is for evolution conditions, in that, there's some extra formatting
		# that needs to be done to enter that: [condition group number]-AND/OR+Stat Value
		# to parse this, I'm going to create a dict of arrays that will contain lines to be parsed
		# each group representing one condition with the first element being the "default" one
		petData.evolutionConditions = []
		var groups : Dictionary[String, Array]
		groups[""] = []
		
		var count = 4
		while count <= 13:
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
				print(condition)
				petData.evolutionConditions.append(condition)
		
		for condition in andConditions:
			print(condition)
			petData.evolutionConditions.append(condition)
		#endregion
		
		#region Parallel Conditions
		# repeating the ENTIRE process to account for parallel Evolution Conditions	14-23
		petData.parallelConditions = []
		groups = {}
		groups[""] = []
		
		count = 14
		while count <= 23:
			if (petDataList[count] == "" or petDataList[count] == "N/A"):
				count += 1
				continue
			
			var statString
			match count:
				14:
					statString = "POW|"
				15:
					statString = "END|"
				16:
					statString = "SPD|"
				17:
					statString = "BAL|"
				18:
					statString = "STATTOTAL|"
				19:
					statString = "TRAUMA|"
				20:
					statString = "CONDITION1|"
				21:
					statString = "CONDITION2|"
				22:
					statString = "CONDITION3|"
				23:
					statString = "CONDITION4|"
					
			if petDataList[count].contains("+"):
				if groups.has(petDataList[count].split("+")[0]):
					groups[petDataList[count].split("+")[0]].append(statString + petDataList[count].split("+")[1])
				else:
					groups[petDataList[count].split("+")[0]] = [statString + petDataList[count].split("+")[1]]
			else:
				groups[""].append(statString + petDataList[count])
			
			count += 1
		
		andConditions = []
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
				print("PARALLEL: ", condition)
				petData.parallelConditions.append(condition)
		
		for condition in andConditions:
			print("PARALLEL ", condition)
			petData.parallelConditions.append(condition)
	
	#endregion
	# Now finally we do evolutions now that we've ensured that all pets from list
	# have been added, to account for parallel evolutions we'll also need to seperate "|"
	print("======================= starting Evoltions ===============")
	for line in lines:
		if line == "":
			continue
		var petDataList : PackedStringArray = line.split("\t")
		var petData = _getResourceFromName(petDataList[0], petDataList[1])
		print("========================", petDataList[1], " ", petData.name , " raw evo data: ", petDataList[3], " ===============")
		petData.evolutions = []
		petData.parallelEvolutions = []
		
		if petDataList[3] != "":
			var evolutionString = petDataList[3]
			var parallelString = ""
			if (petDataList[3].contains("|")):
				evolutionString = petDataList[3].split("|")[0]
				parallelString = petDataList[3].split("|")[1]
			
			for evolutionName in evolutionString.split(","):
				print("evo: ", evolutionName, "-", int(petDataList[1]) + 1, _getResourceFromName(evolutionName, str(int(petDataList[1]) + 1)))
				petData.evolutions.append(_getResourceFromName(evolutionName, str(int(petDataList[1]) + 1)))
			if parallelString != "":
				for evolutionName in parallelString.split(","):
					print("parallel evo: ", evolutionName, "-", petDataList[1], _getResourceFromName(evolutionName, petDataList[1]))
					petData.parallelEvolutions.append(_getResourceFromName(evolutionName, petDataList[1]))
		ResourceSaver.save(petData, _petDataFilePathRoot + "stage_" + petDataList[1] + "/" + _getResourceFileNameFromName(petData.name, petDataList[1]))
	
	
	print("Pet Data Import Complete")


func _getResourceFromName(petName : String, stage : String) -> PetTypeData:
	var fileNames = DirAccess.get_files_at(_petDataFilePathRoot + "stage_" + stage)
	
	for fileName in fileNames:
		var resource = load(_petDataFilePathRoot + "stage_" + stage + "/" + fileName)
		if resource.name == petName:
			return resource
	
	return null


func _getResourceFileNameFromName(petName : String, stage : String) -> String:
	var fileNames = DirAccess.get_files_at(_petDataFilePathRoot + "stage_" + stage)
	
	for fileName in fileNames:
		var resource = load(_petDataFilePathRoot + "stage_" + stage + "/" + fileName)
		if resource.name == petName:
			return fileName
	
	return ""

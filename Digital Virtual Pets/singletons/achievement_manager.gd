extends Node

class DataSaver extends SaveData.DataSaver:
	var _achievementFlags


var _achievementFlags : Dictionary = {
	"EvolveAchiev1" : false,
	"EvolveAchiev2" : false,
	"EvolveAchiev3" : false,
	"EvolveAchiev4" : false,
	"DeathAchiev1" : false,
	"DeathAchiev2" : false,
	"BuhBuhReferenceAchiev" : false,
	"MinigameAchiev" : false,
	"GigaFastAchiev" : false,
	"GigaSlowAchiev" : false,
	"PerfectPetAchiev" : false,
	"ImperfectPetAchiev" : false,
}

func _ready() -> void:
	pass
	#_checkPreReleaseSaveData()
	#_syncAchievWithSteam()


func setAchievementFlag(achievementName : String):
	_achievementFlags[achievementName] = true
	_syncAchievWithSteam()


## Achievements were implemented Prior to the release of the demo. Therefore, 
## we should fill in what achievements we can when the player starts the game
## post release. We can assume certain achievements, like the evolution ones
## are already achieved by using existing save data.
func _checkPreReleaseSaveData():
	var data = SaveData.retrieveGameData("PetManager")
	
	#TODO: Add all checked achievements
	if (!_achievementFlags["EvolveAchiev1"]):
		for petName : String in data.properties["_encounteredPets"].keys():
			var petData = data.properties["_encounteredPets"][petName]
			if (petData.stage > 0):
				_achievementFlags["EvolveAchiev1"] = true
			if (petData.stage > 1):
				_achievementFlags["EvolveAchiev2"] = true
			if (petData.stage > 2):
				_achievementFlags["EvolveAchiev3"] = true
			


## Check each existing achievement bool and check steam if they match. Should set achievements with 
## steam if need be. This is called when starting the game and whenever we update an achiev bool.
func _syncAchievWithSteam():
	for achiev in _achievementFlags.keys():
		var achievement := Steam.getAchievement(achiev)
		if (achievement["ret"]):
			if (_achievementFlags[achiev] and achievement["achieved"]):
				Steam.setAchievement(achiev)
		else:
			print("FAILED TO FIND ACHIEVEMENT: ", achiev)
	
	Steam.storeStats()

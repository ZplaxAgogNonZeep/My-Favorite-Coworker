extends Menu

@export_category("Node References")
@export var _evolutionChart : ChartBuilder
var _petManager : PetManager
var _encounteredPets : Dictionary[String, PetTypeData]

func openMenu(direct := false):
	super(direct)
	_fillEvolutionChart()


func _loadSavedMenuSettings():
	if (PetManager.instance):
		_petManager = PetManager.instance
		PetManager.instance.gatherDataFromActivePet()


func _fillEvolutionChart():
	var progressArray = _petManager.getPetProgressInformation()
	var eggs : Array = progressArray[0]
	_encounteredPets = progressArray[1]
	
	for egg in eggs:
		_evolutionChart.generateTree(egg, _encounteredPets)

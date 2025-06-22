extends Menu

@export_category("Node References")
@export var _evolutionChart : ChartBuilder
@export var _bioName : Label
@export var _bioIcon : TextureRect
@export var _bioParagraph : Label
@export_category("Default Menu Variables")
@export var _defaultIcon : Texture2D
@export var _defaultName : String
@export var _defaultEntry : String
var _petManager : PetManager
var _encounteredPets : Dictionary[String, PetTypeData]

func _ready() -> void:
	_evolutionChart.FillBioData.connect(_fillBioInfo)


func openMenu(direct := false):
	super(direct)
	_fillEvolutionChart()
	# Set Icon
	var tex = CanvasTexture.new()
	tex.diffuse_texture = _defaultIcon
	tex.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_bioIcon.texture = tex
	_bioName.text = _defaultName
	_bioParagraph.text = _defaultEntry


func closeMenu():
	super()
	
	var count = _evolutionChart.get_child_count() - 1
	while (count >= 0):
		_evolutionChart.get_child(count).queue_free()
		count -= 1


func _loadSavedMenuSettings():
	if (PetManager.instance):
		_petManager = PetManager.instance
		PetManager.instance.gatherDataFromActivePet()
		


#region Evolution Chart
func _fillEvolutionChart():
	var progressArray = _petManager.getPetProgressInformation()
	var eggs : Array = progressArray[0]
	_encounteredPets = progressArray[1]
	
	for egg in eggs:
		_evolutionChart.generateTree(egg, _encounteredPets)
#endregion

#region Bio
func _fillBioInfo(petData: PetTypeData):
	_bioName.text = petData.name
	# Set Icon
	var tex = CanvasTexture.new()
	var tex2 = ImageTexture.new()
	var image : Image = petData.getSpriteIcon().get_image()
	tex2.set_image(image)
	
	tex.diffuse_texture = tex2
	tex.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_bioIcon.texture = tex
	_bioParagraph.text = petData.encyclopediaEntry
#endregion

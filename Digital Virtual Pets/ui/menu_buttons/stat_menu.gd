extends Node2D

var implements = [Interface.MenuState]

@export var _panelList : Array[Node2D]
var stateMachine : Node2D
var _index : int

func initializeMenu():
		visible = true
		GameEvents.PauseGame.emit()
		
		if (get_tree().get_nodes_in_group("Pet").size() > 0):
			var pet = PetManager.instance.activePet
			$StatPanel/Personality.text = "Personality:\n" + Enums.Personality.keys()[pet.personality]
			$DisplayPanel/Name.text = pet.petResource.name
			$StatPanel/Pow/Value.text = str(pet.abilityStats[Enums.AbilityStat.POW])
			$StatPanel/End/Value.text = str(pet.abilityStats[Enums.AbilityStat.END])
			$StatPanel/Spd/Value.text = str(pet.abilityStats[Enums.AbilityStat.SPD])
			$StatPanel/Bal/Value.text = str(pet.abilityStats[Enums.AbilityStat.BAL])
			
			$"DisplayPanel/Display Sprite".texture = pet.getSpriteIcon()
			$"DisplayPanel/Display Sprite".offset = pet.sprite.offset
			
			var count = 0
			for i in pet.evolvedFromIcons:
				var iconSprite = get_node_or_null("Display Sprite/EvoHist" + str(count))
				if iconSprite:
					iconSprite.texture = i
				count+=1
				


func exitMenu():
	print("Exit Menu called")
	visible = false
	
	$StatPanel/Personality.text = "Personality:\n??????"
	
	$StatPanel/Pow/Value.text = "0"
	$StatPanel/End/Value.text = "0"
	$StatPanel/Spd/Value.text = "0"
	$StatPanel/Bal/Value.text = "0"
	_index = 0
	
	GameEvents.UnpauseGame.emit()


func takeInput(input : Enums.DeviceButton):
	if (input == Enums.DeviceButton.RIGHT_BUTTON):
		_panelList[_index].visible = false
		_index += 1
		if (_index >= _panelList.size()):
			_index = 0
		if (_index < 0):
			_index = _panelList.size() - 1
		_panelList[_index].visible = true
	if (input == Enums.DeviceButton.LEFT_BUTTON):
		_panelList[_index].visible = false
		_index -= 1
		if (_index >= _panelList.size()):
			_index = 0
		if (_index < 0):
			_index = _panelList.size() - 1
		_panelList[_index].visible = true
	
	if (input == Enums.DeviceButton.CENTER_BUTTON):
		closeMenu()


func closeMenu():
	stateMachine.setState(stateMachine.MenuState.MINIMIZED)

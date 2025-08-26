extends Node2D

var implements = [Interface.MenuState]

@export var _panelList : Array[Node2D]
var stateMachine : Node2D
var _index : int

func initializeMenu():
		visible = true
		#Settings.pauseGame(true)
		GameEvents.PauseTimers.emit()
		
		if (get_tree().get_nodes_in_group("Pet").size() > 0):
			var pet = PetManager.instance.activePet
			# Bio
			$StatPage/Personality.text = "Personality:\n" + Enums.Personality.keys()[pet.personality]
			$BioPage/Name.text = pet.petResource.name
			$"BioPage/Display Sprite".texture = pet.getSpriteIcon()
			$"BioPage/Display Sprite".offset = pet.sprite.offset
			
			# Stats
			$StatPage/Pow/Value.text = str(pet.abilityStats[Enums.AbilityStat.POW])
			$StatPage/StatGraphs/POWMeter.setValue(pet.abilityStats[Enums.AbilityStat.POW], Pet.STAT_MAX)
			$StatPage/End/Value.text = str(pet.abilityStats[Enums.AbilityStat.END])
			$StatPage/StatGraphs/ENDMeter.setValue(pet.abilityStats[Enums.AbilityStat.END], Pet.STAT_MAX)
			$StatPage/Spd/Value.text = str(pet.abilityStats[Enums.AbilityStat.SPD])
			$StatPage/StatGraphs/SPDMeter.setValue(pet.abilityStats[Enums.AbilityStat.SPD], Pet.STAT_MAX)
			$StatPage/Bal/Value.text = str(pet.abilityStats[Enums.AbilityStat.BAL])
			$StatPage/StatGraphs/BALMeter.setValue(pet.abilityStats[Enums.AbilityStat.BAL], Pet.STAT_MAX)
			
			
			var count = 0
			for i in pet.evolvedFromIcons:
				var iconSprite = get_node_or_null("Display Sprite/EvoHist" + str(count))
				if iconSprite:
					iconSprite.texture = i
				count+=1
				


func exitMenu():
	visible = false
	
	$StatPage/Personality.text = "Personality:\n??????"
	
	$StatPage/Pow/Value.text = "0"
	$StatPage/End/Value.text = "0"
	$StatPage/Spd/Value.text = "0"
	$StatPage/Bal/Value.text = "0"
	_index = 0
	
	GameEvents.UnpauseTimers.emit()


func takeInput(input : Enums.DeviceButton):
	stateMachine.playBeep()
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

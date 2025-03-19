extends Panel

var implements = [Interface.MenuState]

var stateMachine : Node2D

func initializeMenu():
		visible = true
		GameEvents.PauseGame.emit()
		
		if (get_tree().get_nodes_in_group("Pet").size() > 0):
			var pet = get_tree().get_nodes_in_group("Pet")[0]
			$Personality.text = "Personality: " + Enums.Personality.keys()[pet.personality]
			$Name.text = pet.petResource.name
			$Pow/Value.text = str(pet.abilityStats[Enums.AbilityStat.POW])
			$End/Value.text = str(pet.abilityStats[Enums.AbilityStat.END])
			$Spd/Value.text = str(pet.abilityStats[Enums.AbilityStat.SPD])
			$Bal/Value.text = str(pet.abilityStats[Enums.AbilityStat.BAL])
			
			$"Display Sprite".texture = pet.getSpriteIcon()
			$"Display Sprite".offset = pet.sprite.offset
			
			var count = 0
			for i in pet.evolvedFromIcons:
				var iconSprite = get_node_or_null("Display Sprite/EvoHist" + str(count))
				if iconSprite:
					iconSprite.texture = i
				count+=1
				


func exitMenu():
	print("Exit Menu called")
	visible = false
	
	$Personality.text = "Personality: ??????"
	
	$Pow/Value.text = "00"
	$End/Value.text = "00"
	$Spd/Value.text = "00"
	$Bal/Value.text = "00"
	
	GameEvents.UnpauseGame.emit()


func takeInput(input : Enums.DeviceButton):
	if (input == Enums.DeviceButton.CENTER_BUTTON):
		closeMenu()


func closeMenu():
	stateMachine.setState(stateMachine.MenuState.MINIMIZED)

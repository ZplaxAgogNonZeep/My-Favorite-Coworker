extends Panel

var implements = [Interface.MenuState]

var stateMachine : Node2D

func initializeMenu():
		visible = true
		GameEvents.PauseGame.emit()
		
		if (get_tree().get_nodes_in_group("Pet").size() > 0):
			var pet = get_tree().get_nodes_in_group("Pet")[0]
			$Personality.text = "Personality: " + Enums.Personality.keys()[pet.personality]
			
			$Pow/Value.text = str(pet.abilityStats[Enums.AbilityStat.POW])
			$End/Value.text = str(pet.abilityStats[Enums.AbilityStat.END])
			$Spd/Value.text = str(pet.abilityStats[Enums.AbilityStat.SPD])
			$Bal/Value.text = str(pet.abilityStats[Enums.AbilityStat.BAL])


func exitMenu():
	print("Exit Menu called")
	visible = false
	
	$Personality.text = "Personality: ??????"
	
	$Pow/Value.text = "00"
	$End/Value.text = "00"
	$Spd/Value.text = "00"
	$Bal/Value.text = "00"
	
	GameEvents.UnpauseGame.emit()


func takeInput(input : Enums.InputType):
	if (input == Enums.InputType.MIDDLEBUTTON):
		closeMenu()


func closeMenu():
	stateMachine.setState(stateMachine.MenuState.MINIMIZED)

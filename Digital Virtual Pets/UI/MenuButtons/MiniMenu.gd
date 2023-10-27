extends Panel

var implements = [Interface.MenuState]

@export var buttonController : Node

var stateMachine : Node2D

func _ready():
	$Feed.ButtonSelected.connect(onFeedSelected)
	$Play.ButtonSelected.connect(onPlaySelected)
	$Stats.ButtonSelected.connect(onStatsSelected)


func takeInput(input : Enums.InputType):
	if (buttonController.active):
		match input:
			Enums.InputType.LEFTBUTTON:
				buttonController.cycle(-1)
			Enums.InputType.RIGHTBUTTON:
				buttonController.cycle(1)
			Enums.InputType.MIDDLEBUTTON:
				buttonController.select()
	else:
		buttonController.setActive(true)
	


func onFeedSelected():
	print("Feed Selected")
	GameEvents.FeedPet.emit()


func onPlaySelected():
	pass


func onStatsSelected():
	pass

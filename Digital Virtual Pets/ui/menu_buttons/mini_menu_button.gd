extends Node2D

var implements = [Interface.HighlightButton]

signal ButtonSelected

@export var highlightSprite : Sprite2D
@export var icon : AnimatedSprite2D

var isHighlighted := false
var isEnabled := true

func initializeButton():
	toggleHighlight(false)


func toggleDisable(isEnabled : bool):
	self.isEnabled = isEnabled
	visible = isEnabled

func toggleHighlight(highlight : bool):
	isHighlighted = highlight
	
	if (highlight):
		highlightSprite.visible = true
		icon.animation = "Selected"
	else:
		highlightSprite.visible = false
		icon.animation = "Unselected"


func selectButton():
	if (isEnabled):
		ButtonSelected.emit()

extends Control

var implements = [Interface.HighlightButton]

signal ButtonSelected

@onready var rect := $SelectionRect
@onready var label := $OptionName

var isHighlighted := false
var isEnabled := true

func initializeButton():
	toggleHighlight(true)

func toggleHighlight(highlight: bool):
	isHighlighted = highlight
	
	if (highlight):
		rect.color = Color(0,0,0)
		label.add_theme_color_override("font_color", Color("d5ded5"))
	else:
		rect.color = Color("d5ded5")
		label.add_theme_color_override("font_color", Color(0, 0, 0))

func selectButton():
	ButtonSelected.emit()

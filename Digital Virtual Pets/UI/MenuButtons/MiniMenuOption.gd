extends Control

var implements = [Interface.HighlightButton]

signal ButtonSelected

@onready var rect := $SelectionRect
@onready var label := $OptionName
@onready var icon := $OptionIcon

var isHighlighted := false

func _ready():
	initializeButton()

func initializeButton():
	toggleHighlight(false)


func toggleHighlight(highlight : bool):
	isHighlighted = highlight
	
	if (highlight):
		rect.color = Color(0,0,0)
		label.add_theme_color_override("font_color", Color("d5ded5"))
		icon.animation = "Selected"
	else:
		rect.color = Color("d5ded5")
		label.add_theme_color_override("font_color", Color(0, 0, 0))
		icon.animation = "Unselected"


func selectButton():
	ButtonSelected.emit()

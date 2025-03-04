extends Panel

var baseLabelSize
var positionOffset

func _ready() -> void:
	await get_tree().process_frame
	print("Updating label size", $Label.size.y)
	
	if (baseLabelSize < $Label.size.y):
		var diff = $Label.size.y - baseLabelSize
		size.y += diff


func loadWindow(pos : Vector2, text : String):
	positionOffset = position
	baseLabelSize = $Label.size.y
	position = pos + positionOffset
	
	
	$Label.text = text
	
	

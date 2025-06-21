extends Button

@export var _markers : Array[Marker2D]


func getTrueSize() -> Vector2:
	return size + Vector2(0,$Name.size)

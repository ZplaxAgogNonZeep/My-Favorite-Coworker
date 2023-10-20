extends Node2D

var implements = [Interface.Food]

var feedAmount := 50
var fallSpeed := 1
var stopFallingAt : int
var readyToEat := false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (position.y < stopFallingAt):
		position.y += fallSpeed
	else:
		if not readyToEat:
			readyToEat = true
			GameEvents.FoodPlaced.emit()
			


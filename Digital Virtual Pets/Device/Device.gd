extends Node2D

@export
var activePet : Node2D

var chatSpeed := 1

enum test {doot, door, moors}
var testy = test.doot

# Called when the node enters the scene tree for the first time.
func _ready():
	if testy == 0:
		print("It works")
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

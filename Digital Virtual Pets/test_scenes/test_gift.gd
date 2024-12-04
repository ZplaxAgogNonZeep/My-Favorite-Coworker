extends Node2D

@export var gift : Node2D

var implements = []

# Called when the node enters the scene tree for the first time.
func _ready():
	gift.authenticate()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


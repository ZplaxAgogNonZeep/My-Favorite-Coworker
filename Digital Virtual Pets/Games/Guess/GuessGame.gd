extends Control

var implements = [Interface.MiniGame]

var connectedPet : Node2D
var gameRunning := false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if gameRunning:
		pass

func startGame(pet : Node2D):
	connectedPet = pet
	$PseudoPet.sprite.set_sprite_frames(pet.sprite.sprite_frames)
	$PseudoPet.sprite.animation = "Idle"
	$PseudoPet.indicateDirection(true)
	gameRunning = true

func onWin():
	print("You Won!")

func onLose():
	print("You Lose!")

func endGame():
	pass

func takeInput(input : Enums.InputType):
		pass

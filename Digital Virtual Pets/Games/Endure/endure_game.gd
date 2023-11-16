extends Control

var implements = [Interface.MiniGame]

@export_category("Stat Values")
@export var joyIncrement : int
@export var statIncrement : int
@export var statToIncrement : Enums.AbilityStat
@export_category("Game Values")
@export var mashMax : int
@export var mashGoalMin : int
@export var mashGoalMax : int

var playMenu : Panel
var connectedPet : Node2D
var gameRunning : bool

func startGame(pet : Node2D, playMenu : Panel):
	connectedPet = pet
	self.playMenu = playMenu
	$PseudoPet.sprite.set_sprite_frames(pet.sprite.sprite_frames)
	$PseudoPet.sprite.offset = pet.sprite.offset
	$PseudoPet.sprite.animation = "Idle"
	$MashMeter.initializeMeter(mashMax, mashGoalMin, mashGoalMax)
	
	gameRunning = true

func endGame():
	pass

func takeInput(input : Enums.InputType):
	pass

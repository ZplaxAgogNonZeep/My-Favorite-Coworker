extends Node2D

class_name Minigame

enum StatToIncrement {POW, END, SPD, BAL, RANDOM}
enum DifficultyLevel {EASY, MEDIUM, HARD, VERY_HARD}

@export_category("Debug")
@export var _overrideDifficulty : DifficultyLevel
@export var _useOverride : bool
@export_category("Reward Stats")
@export var joyIncrement : int
@export var _connectedStat : StatToIncrement
@export var statIncrement : int
@export_category("Music & Sound")
@export var _music : MusicTrack
@export var _soundEffects : Array[SoundGroup]
@export_category("Display Text")
@export var _label : Label

var playMenu : Node2D
var connectedPet : Node2D
var gameRunning : bool
var _difficulty : DifficultyLevel

func startGame(pet : Node2D, playMenu : Node2D):
	SfxManager.playMusic(_music)
	connectedPet = pet
	if (_useOverride):
		_difficulty = _overrideDifficulty
	else:
		_difficulty = calcDifficulty(connectedPet.abilityStats)
	self.playMenu = playMenu
	$PseudoPet.sprite.set_sprite_frames(pet.sprite.sprite_frames)
	$PseudoPet.sprite.offset = pet.sprite.offset


func endGame():
	playMenu.closeMenu()
	queue_free()


func takeInput(input : Enums.DeviceButton):
	pass


func onWin():
	print("WIN")
	SfxManager.incrementMusic(1)
	$PseudoPet.sprite.play("Quirk")
	if (_connectedStat == StatToIncrement.RANDOM):
		randomize()
		var statToIncrease = randi_range(0,3)
		connectedPet.receivePlay(100, statToIncrease, statIncrement)
	else:
		connectedPet.receivePlay(100, _connectedStat, statIncrement)
	
	if (SfxManager.isPlayingMusic()):
		await SfxManager.MusicFinished
	else:
		await get_tree().create_timer(1).timeout
	endGame()


func onLose():
	print("LOSE")
	SfxManager.incrementMusic(0)
	if (_connectedStat == StatToIncrement.RANDOM):
		randomize()
		var statToIncrease = randi_range(0,3)
		connectedPet.receivePlay(75, statToIncrease, 1)
	else:
		connectedPet.receivePlay(75, _connectedStat, 1)
	if (SfxManager.isPlayingMusic()):
		await SfxManager.MusicFinished
	else:
		await get_tree().create_timer(1).timeout
	endGame()


func calcDifficulty(petStats : Dictionary) -> DifficultyLevel:
	if (_connectedStat == StatToIncrement.RANDOM):
		return DifficultyLevel.EASY
	var statValue = petStats[_connectedStat]
	
	if statValue >= 36:
		return DifficultyLevel.VERY_HARD
	elif statValue >= 25:
		return DifficultyLevel.HARD
	elif statValue >= 12:
		return DifficultyLevel.MEDIUM
	else:
		return DifficultyLevel.EASY


func updateGameText(text : String):
	$Status.text = text

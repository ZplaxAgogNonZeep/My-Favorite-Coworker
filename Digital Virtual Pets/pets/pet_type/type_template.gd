extends Node

class_name PetType

@export var tempEvolveCondition = true
@export var petName : String
@export var moveTimer : Timer
@export var neglectTimer : Timer
@export var waitIntervalMax := 10.0
@export var waitIntervalMin := 3.0

@onready var pet = get_parent()

func _ready() -> void:
	moveTimer.connect("timeout", _onMoveTimerTimeout)

func roamBehavior() -> void:
	if not pet.isRoaming and moveTimer.is_stopped():
		randomize()
		moveTimer.start(randf_range(waitIntervalMin, waitIntervalMax))

func feedingBehavior() -> void:
	pass

func onTickHunger() -> void:
	pass

func onTickJoy() -> void:
	pass

func onEatFood() -> void:
	pass

func getEvolvePet() -> Pet:
	return null

func _onMoveTimerTimeout() -> void:
	pet.goToPosition(pet.getNextPosition())

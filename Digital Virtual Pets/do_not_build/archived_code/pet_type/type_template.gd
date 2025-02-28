extends Node

class_name PetType

@onready var pet : Pet = get_parent()

@export var tempEvolveCondition = true
@export_category("Object References")
@export var moveTimer : Timer
@export var neglectTimer : Timer
@export_category("Variables")
@export var petName : String
@export var waitIntervalMax := 10.0
@export var waitIntervalMin := 3.0

var petResource : PetTypeData

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

func getEvolvePet():
	return null

func _onMoveTimerTimeout() -> void:
	pet.goToPosition(pet.getNextPosition())

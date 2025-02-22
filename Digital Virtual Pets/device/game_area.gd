extends Node2D

const TIMER_TIME := 5

@export_category("Object References")
@export var device : Node2D
#@export var activePet : Node2D
@export var objectContainer : Node2D
@export var petManager : Node2D
@export var menuManager : Node2D
@export var boundries : Array[Marker2D] # 0 = Left | 1 = Right
@export var ObjectSpawnLocations : Array[Marker2D]
@export_category("Spawnable Objects")
@export var foodInstance : PackedScene

var evolveInterval = 15

var _spawnpointStatus = [true, true, true, true]

func _ready():
	GameEvents.NewPetSpawned.connect(petSpawned)
	GameEvents.FeedPet.connect(feed)
	GameEvents.ClearObjects.connect(clearAllObjects)
	GameEvents.StartNeedsTimers.connect(_startNeedsTimers)
	
	#GameEvents.SpawnPetOnStart.emit()
	petManager.spawnPet(0)
	
	await get_tree().create_timer(5).timeout


func _process(delta: float) -> void:
	_proactivityBehavior()


func _unhandled_input(event):
	if Input.is_action_just_pressed("Debug"):
		_evolveCheck()
		#test()

#region Window Events

func _proactivityBehavior():
	if (!Settings.isUsingProactivity):
		return
	
	Settings.windowFocused = DisplayServer.window_is_focused()
	
	if (Settings.windowFocused and Settings.proactiveMode):
		Settings.setProactivityMode(false)
	elif (not Settings.windowFocused and not Settings.proactiveMode):
		Settings.setProactivityMode(true)


func _requestPlayerAttention():
	if (Settings.windowFocused or not Settings.isRequestAttentionAllowed):
		return
	
	if (Settings.isSetWindowPinned):
		DisplayServer.window_request_attention()
	else:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, false)

#endregion

#region Events 

func feed():
	var food = foodInstance.instantiate()
	food.stopFallingAt = boundries[0].position.y
	if (not _spawnpointStatus.has(true)):
		food.queue_free()
		return
	while true:
		randomize()
		var spawnNumber = randi_range(0, 3)
		if (_spawnpointStatus[spawnNumber]):
			food.position = ObjectSpawnLocations[spawnNumber].position
			break
	objectContainer.add_child(food)

func petSpawned(isEgg := false):
	if (!isEgg):
		_startNeedsTimers()
	$GameTimers/EvolveTimer.start(Pet.EVOLVE_INTERVALS[petManager.getPetStage()])


func _startNeedsTimers():
	randomize()
	$GameTimers/HungerTimer.start((randf_range(3, 15)) * Settings.getTimerMod())
	randomize()
	$GameTimers/JoyTimer.start((randf_range(3, 15)) * Settings.getTimerMod())


func clearAllObjects():
	for x in range(objectContainer.get_child_count()):
		objectContainer.get_child(x).queue_free()

#endregion

#region Timer Controls 

func tickHunger():
	GameEvents.TickHunger.emit()
	randomize()
	$GameTimers/HungerTimer.start((randf_range(3, 15)) * Settings.getTimerMod())


func tickJoy():
	GameEvents.TickJoy.emit()
	randomize()
	$GameTimers/JoyTimer.start((randf_range(3, 15)) * Settings.getTimerMod())


func _evolveCheck():
	print("Check for Evolve!")
	GameEvents.EvolveCheck.emit()
	$GameTimers/EvolveTimer.start(evolveInterval * Settings.getTimerMod())

#endregion

#region Signals

func _foodColliderEntered(body, number = 0):
	if (Interface.hasInterface(body, Interface.Food)):
		_spawnpointStatus[number] = false

func _foodColliderExited(body, number = 0):
	if (Interface.hasInterface(body, Interface.Food)):
		_spawnpointStatus[number] = true

#endregion

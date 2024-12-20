extends Pet

class_name Egg 

var implements = []

func _ready():
	GameEvents.PauseGame.connect(gamePaused)
	GameEvents.UnpauseGame.connect(gameUnpaused)


func _process(delta: float) -> void:
	pass



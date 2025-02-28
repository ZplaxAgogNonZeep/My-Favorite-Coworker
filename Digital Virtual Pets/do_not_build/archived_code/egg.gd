extends Pet

class_name Egg 

var implements = []

func _ready():
	GameEvents.EvolveCheck.connect(evolvePet)
	GameEvents.PauseGame.connect(gamePaused)
	GameEvents.UnpauseGame.connect(gameUnpaused)
	
	sprite.play("Idle")


func _process(delta: float) -> void:
	pass



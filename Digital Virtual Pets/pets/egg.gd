extends Pet

class_name Egg 

var implements = []

func _ready():
	GameEvents.PauseGame.connect(gamePaused)
	GameEvents.UnpauseGame.connect(gameUnpaused)
	
	sprite.play("Idle")


func _process(delta: float) -> void:
	pass



extends AnimatedSprite2D


func _ready() -> void:
	GameEvents.PetMoodChange.connect(_displayMood)
	visible = false

func _displayMood(mood : ThoughtBubble.PetMood, time : float):
	if (mood == ThoughtBubble.PetMood.NONE):
		return
	
	visible = true
	
	match mood:
		ThoughtBubble.PetMood.TRAUMA:
			play("Trauma")
		ThoughtBubble.PetMood.HAPPY:
			play("Happy")
		ThoughtBubble.PetMood.SAD:
			play("Sad")
		ThoughtBubble.PetMood.MAD:
			play("Mad")
		ThoughtBubble.PetMood.DYING:
			play("Dying")
	
	await get_tree().create_timer(time).timeout
	visible = false

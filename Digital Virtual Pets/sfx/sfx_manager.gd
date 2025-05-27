extends Node

enum BusType {MASTER, DEVICE, GAME}


func playSoundEffect(effectGroup : SoundGroup):
	if (effectGroup == null):
		return
	var effectPlayer = AudioStreamPlayer.new()
	effectPlayer.pitch_scale = randf_range(.75, 1.25)
	effectPlayer.autoplay = true
	effectPlayer.stream = effectGroup.getStream()
	match effectGroup.bus:
		BusType.GAME:
			effectPlayer.bus = "Game"
		BusType.DEVICE:
			effectPlayer.bus = "Device"
	await get_tree().root.call_deferred("add_child", effectPlayer)
	await effectPlayer.finished
	effectPlayer.queue_free()

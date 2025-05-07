extends Node

enum BusType {MASTER, DEVICE, GAME}


func playSoundEffect(effectGroup : SoundGroup):
	var effectPlayer = AudioStreamPlayer.new()
	effectPlayer.autoplay = true
	effectPlayer.stream = effectGroup.getStream()
	print(effectGroup)
	match effectGroup.bus:
		BusType.GAME:
			effectPlayer.bus = "Game"
		BusType.DEVICE:
			effectPlayer.bus = "Device"
	await get_tree().root.call_deferred("add_child", effectPlayer)
	await effectPlayer.finished
	effectPlayer.queue_free()

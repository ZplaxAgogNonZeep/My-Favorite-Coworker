extends Resource

class_name SoundGroup

@export var _audioStreams : Array[AudioStream]
@export var bus : SfxManager.BusType

func getStream() -> AudioStream:
	return _audioStreams[randi_range(0, _audioStreams.size() - 1)]

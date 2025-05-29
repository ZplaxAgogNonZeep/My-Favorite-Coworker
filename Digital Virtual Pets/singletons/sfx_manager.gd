extends Node

enum BusType {MASTER, DEVICE, GAME}

class MusicInstance:
	var _track : MusicTrack
	var _partIndex : int
	var _streamIndex : int
	var _nextStream : AudioStream
	var _player : AudioStreamPlayer
	
	# FINISH THIS
	func _init() -> void:
		pass
	
	
	func startMusic(startingStreamIndex := -1):
		var streamToPlay
		var part : Array
		
		if (_track.trackIntro.size() > 0):
			part = _track.trackIntro
			_partIndex = 0
		else:
			_partIndex = 1
			part = _track.trackBody
		
		if (startingStreamIndex >= 0):
			streamToPlay = part[startingStreamIndex]
			_streamIndex = startingStreamIndex
		else:
			if (_track.trackIntro.size() > 0):
				match _track.introProgression:
					MusicTrack.ProgressionType.INCREMENTAL:
						streamToPlay = part[0]
						_streamIndex = 0
					MusicTrack.ProgressionType.RANDOMIZE:
						_streamIndex = randi_range(0, part.size() - 1)
						streamToPlay = part[_streamIndex]
					MusicTrack.ProgressionType.DIRECT_CALL:
						streamToPlay = part[0]
						_streamIndex = 0
			else:
				match _track.bodyProgression:
					MusicTrack.ProgressionType.INCREMENTAL:
						_streamIndex = 0
						streamToPlay = part[0]
					MusicTrack.ProgressionType.RANDOMIZE:
						_streamIndex = randi_range(0, part.size() - 1)
						streamToPlay = part[_streamIndex]
					MusicTrack.ProgressionType.DIRECT_CALL:
						_streamIndex = 0
						streamToPlay = part[0]
		
		_player.stream = streamToPlay
		_player.play()
	
	
	func incrementPart(streamIndex := -1, addToQueue := true):
		if (_partIndex == 2):
			stopMusic()
			return
		
		_partIndex += 1
		var streamToPlay
		var part
		var progression
		match _partIndex:
			0:
				part = _track.trackIntro
			1:
				part = _track.trackBody
			2:
				part = _track.trackOutro
		
		if (streamIndex >= 0):
			streamToPlay = part[streamIndex]
			_streamIndex = streamIndex
		else:
			match progression:
				MusicTrack.ProgressionType.INCREMENTAL:
					_streamIndex = 0
				MusicTrack.ProgressionType.RANDOMIZE:
					_streamIndex = randi_range(0, part.size() - 1)
				MusicTrack.ProgressionType.DIRECT_CALL:
					_streamIndex = 0
		
		streamToPlay = part[_streamIndex]
		_nextStream = streamToPlay
	
	
	func changeStreamIndex(index : int):
		pass
	
	
	func stopMusic():
		pass
	
	
	func streamComplete():
		if (_nextStream != null):
			_player.stream = _nextStream
			_player.play()
			return
		
		var partChange
		var progression
		var streamToPlay
		match _partIndex:
			0:
				partChange = _track.introChange
				progression = _track.introProgression
			1:
				partChange = _track.PartChange
				progression = _track.bodyProgression
			2:
				partChange = _track.conclusion
				progression = _track.outroProgression
		
		match partChange:
			MusicTrack.PartChangeType.ONESHOT:
				incrementPart(-1, false)
				return
			MusicTrack.PartChangeType.LOOP:
				match progression:
					MusicTrack.ProgressionType.INCREMENTAL:
						_streamIndex += 1
					MusicTrack.ProgressionType.RANDOMIZE:
						_streamIndex = randi_range(0, _track.getPartByIndex(_partIndex).size() - 1)
		
		_player.stream = _track.getPartByIndex(_partIndex)[_streamIndex]
		_player.play()

var _musicPlayer : AudioStreamPlayer
var _musicResource : MusicTrack

func _ready() -> void:
	var musicPlayer = AudioStreamPlayer.new()
	musicPlayer.autoplay = false
	musicPlayer.bus = "Game"
	await get_tree().root.call_deferred("add_child", musicPlayer)


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

func playMusic():
	pass

extends Resource
#TODO: Document
class_name MusicTrack

enum ProgressionType {INCREMENTAL, RANDOMIZE, DIRECT_CALL}
enum PartChangeType {ONESHOT, LOOP}

@export var name : String
@export_category("Track Parts")
@export var trackIntro : Array[AudioStream]
@export var trackBody : Array[AudioStream]
@export var trackOutro : Array[AudioStream]

@export_category("Track Intro Settings")
@export var introProgression : ProgressionType
@export var introChange : PartChangeType
@export_category("Track Body Settings")
@export var bodyProgression : ProgressionType
@export var PartChange : PartChangeType ## Determines whether or not the track should progress to the next or remain where it is. Looping behavior is determined by the [param _bodyProgression].
@export var keepTimestamp : bool ## If [param true], the progress through a track will be kept when changed.
@export_category("Track Outro Settings")
@export var outroProgression : ProgressionType
@export var conclusion : PartChangeType


func getPartByIndex(index : int) -> Array:
	var returnList : Array
	match index:
		0:
			returnList = trackIntro
		1:
			returnList = trackBody
		2:
			returnList = trackOutro
	return returnList

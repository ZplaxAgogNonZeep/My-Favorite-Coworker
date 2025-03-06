extends Control

class_name DialogSystem

class DialogThread:
	var dialogResource : CharacterDialog
	var rootName : String
	var rootPosn : Vector2
	var threadIndex : int
	var thread : Array[Dictionary]
	var activePassage : Dictionary
	
	func _init(_dialogResource : CharacterDialog, _rootName : String, _rootPosn : Vector2, index) -> void:
		dialogResource = _dialogResource
		rootName = _rootName
		rootPosn = _rootPosn
		threadIndex = index
		
		activePassage = dialogResource.getConversationByName(rootName)
	
	
	func continueDialog(linkIndex : int):
		thread.append(activePassage)
		
		if (linkIndex > 0):
			activePassage = dialogResource.getPassageByName(activePassage["links"][linkIndex]["passageName"])
		else:
			activePassage = {}
	
	
	func getLinks() -> Array[String]:
		var links = []
		
		for linkDict : Dictionary in activePassage["links"]:
			links.append(linkDict["linkText"])
		
		return links
	
	
	func getPassageText() -> String:
		return activePassage["cleanText"]
	
	
	func getSpeaker() -> String:
		#TODO: Update this to format name string and to account for things like multiple speakers
		if (thread.size() == 0):
			return dialogResource.characterName
		else:
			return activePassage["tags"]


@export var _systemWindowScene : PackedScene
var _threads : Array[DialogThread] = []

func _ready() -> void:
	GameEvents.DisplayDialog.connect(_callSystemDialog)


func _callSystemDialog(pos : Vector2, dialogResource : CharacterDialog, conversationName : String):
	var newThread = DialogThread.new(dialogResource, conversationName, pos, _threads.size())
	_threads.append(newThread)
	_createDialogWindow(pos, newThread)


func _createDialogWindow(pos : Vector2, thread : DialogThread):
	var newDialog = _systemWindowScene.instantiate()
	newDialog.loadWindow(pos, thread.getPassageText(), thread.getSpeaker(), thread.getLinks())
	newDialog.DialogChoiceSelected.connect(_continueDialog)
	
	call_deferred("add_child", newDialog)


func removeThread():
	pass


func _clearDialog():
	pass


func _continueDialog(index : int):
	pass

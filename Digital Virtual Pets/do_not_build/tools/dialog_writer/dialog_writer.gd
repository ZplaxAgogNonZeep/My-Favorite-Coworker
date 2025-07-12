@tool
extends Node

const DIALOG_FILEPATH := "res://data/dialog/"

#TODO: Document
@export_tool_button("Generate Dialog Resources")
var x: Callable = _generateDialog
@export var dialogText : JSON
@export_category("Formatting Settings")

var _passageList : Array

func _generateDialog():
	print("Generating dialog from JSON file")
	
	#var test = CharacterDialog.new()
	#test.doot = "meeple"
	#ResourceSaver.save(test, "res://test_dialog.tres")
	
	var dataReceived = dialogText.data
	
	if (typeof(dataReceived) == TYPE_DICTIONARY):
		if (typeof(dataReceived["passages"]) == TYPE_ARRAY):
			_createDialogFiles(dataReceived["passages"])
		else:
			print("DIALOG WRITER ERROR: Unexpected Format in Passages, please re-export file and try again.")
	else:
		print("DIALOG WRITER ERROR: Unexpected Format, please re-export file and try again.")

func _createDialogFiles(rawDialog : Array):
	_passageList = rawDialog.duplicate(true)
	var characterList : Array[Array] = []
	var characterConversations : Dictionary[String, Array]
	
	# Creats a list of characters to make resources for
	# characters are determined by the first tag in a passage
	for passage : Dictionary in rawDialog:
		if (passage["tags"] != ""):
			var tags : Array = passage["tags"].split(" ", false)
			
			if (tags.size() > 1):
				if (tags[0].rstrip(" ") == "Conversation-Start"):
					if (characterConversations.has(tags[1])):
						characterConversations[tags[1]].append(passage)
					else:
						characterConversations[tags[1]] = [passage]
	
	for characterName in characterConversations.keys():
		var characterDialog := CharacterDialog.new()
		
		characterDialog.characterName = characterName
		for conversation in characterConversations[characterName]:
			characterDialog.conversations[conversation["name"]] = conversation
		
		#characterDialog.conversations = characterConversations[characterName].duplicate(true)
		for conversationName : String in characterDialog.conversations.keys():
			var linkedPassage = _getPassageByName(conversationName)
			characterDialog.passages[linkedPassage["name"]] = linkedPassage
			_getAllLinkedPassages(characterDialog.conversations[conversationName], characterDialog)
		
		ResourceSaver.save(characterDialog, DIALOG_FILEPATH + characterName.to_lower() + ".tres")
	print("Wrote dialog to resources at " + DIALOG_FILEPATH)


func _getAllLinkedPassages(passage : Dictionary, resource : CharacterDialog):
	if (passage.has("links")):
		for link : Dictionary in passage["links"]:
			var linkedPassage = _getPassageByName(link["passageName"])
			resource.passages[linkedPassage["name"]] = linkedPassage
			_getAllLinkedPassages(linkedPassage, resource)
		
		


func _getPassageByName(passageName : String) -> Dictionary:
	for passage : Dictionary in _passageList:
		if (passage["name"] == passageName):
			return passage
	return {}

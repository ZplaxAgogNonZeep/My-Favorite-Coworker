extends Resource

class_name CharacterDialog

@export var characterName : String
@export var conversations : Dictionary

@export var passages : Dictionary

func getPassageByName(passageName : String) -> Dictionary:
	return passages[passageName]


func getConversationByName(conversationName : String) -> Dictionary:
	return conversations[conversationName]


func getLinkedPassages(passage : Dictionary) -> Array[Dictionary]:
	var links = []
	for link in passage["links"]:
		links.append(getPassageByName(link["passageName"]))
	return links

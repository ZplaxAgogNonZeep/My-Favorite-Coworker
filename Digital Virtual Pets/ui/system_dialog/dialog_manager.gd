extends Control

class_name DialogSystem

class DialogThread:
	var dialogResource : CharacterDialog
	var rootName : String
	var rootPosn : Vector2
	var threadIndex : int
	var thread : Array[Dictionary]
	var activePassage : Dictionary
	var returnFunction : Callable
	
	func _init(_dialogResource : CharacterDialog, _rootName : String, 
				_rootPosn : Vector2, index : int, _returnFunction : Callable) -> void:
		dialogResource = _dialogResource
		rootName = _rootName
		rootPosn = _rootPosn
		threadIndex = index
		returnFunction = _returnFunction
		
		activePassage = dialogResource.getConversationByName(rootName)
	
	
	func continueDialog(linkIndex : int):
		thread.append(activePassage)
		
		if (linkIndex >= 0):
			activePassage = dialogResource.getPassageByName(activePassage["links"][linkIndex]["passageName"])
		else:
			activePassage = {}
	
	#region Getter Functions
	func getLinks() -> Array[String]:
		var links : Array[String] = []
		
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
	#endregion


@export var _systemWindowScene : PackedScene
var _threads : Array[DialogThread] = []
var _windows : Array[Array]

func _ready() -> void:
	GameEvents.DisplayDialog.connect(_callSystemDialog)


func _callSystemDialog(pos : Vector2, dialogResource : CharacterDialog, 
						conversationName : String, returnFunction : Callable):
	var newThread = DialogThread.new(dialogResource, conversationName, pos, _threads.size(), returnFunction)
	_threads.append(newThread)
	_windows.append([])
	_createDialogWindow(pos, newThread)


func _continueDialog(linkIndex : int, threadIndex : int, window : Control):
	_threads[threadIndex].continueDialog(linkIndex)
	_closeWindow(threadIndex, window)
	
	if (_threads[threadIndex].activePassage.keys().size() > 0):
		# we have a correct passage
		print("continueing dialog")
		_createDialogWindow(_threads[threadIndex].rootPosn, _threads[threadIndex])
	else:
		print("No more dialog")
		# empty dict, no more links, end dialog
		_threads[threadIndex].returnFunction.call(_threads[threadIndex].thread)
		_removeThread()


#region Utility Functions
func _createDialogWindow(pos : Vector2, thread : DialogThread):
	var newDialog = _systemWindowScene.instantiate()
	newDialog.loadWindow(pos, thread.getPassageText(), 
								thread.getSpeaker(), 
								thread.getLinks(), 
								thread.threadIndex)
	newDialog.DialogChoiceSelected.connect(_continueDialog)
	_windows[thread.threadIndex].append(newDialog)
	call_deferred("add_child", newDialog)


func _closeWindow(threadIndex : int, closeWindow : Control):
	_windows[threadIndex].erase(closeWindow)
	closeWindow.queue_free()


func _removeThread():
	#TODO: NEED something that updates all the thread indexes in the windows and in the threads
	pass


func _clearDialog():
	pass
#endregion

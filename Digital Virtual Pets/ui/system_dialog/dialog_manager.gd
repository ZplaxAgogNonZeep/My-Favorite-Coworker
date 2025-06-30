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
		
		if (activePassage["links"].size() == 0):
			activePassage = {}
		elif (linkIndex >= 0):
			activePassage = dialogResource.getPassageByName(activePassage["links"][linkIndex]["passageName"])
		else:
			activePassage = {}
	
	
	func completeThread():
		returnFunction.call(thread)
	
	
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
@export var _windowPosnVariance : Vector2
var _threads : Array[DialogThread] = []
var _windows : Array[Array]

func _ready() -> void:
	GameEvents.DisplayDialog.connect(_callSystemDialog)


func _callSystemDialog(pos : Vector2i, dialogResource : CharacterDialog, 
						conversationName : String, returnFunction : Callable) -> void:
	if (dialogResource == null):
		return
	Settings.pauseGame(true)
	var newThread = DialogThread.new(dialogResource, conversationName, pos, _threads.size(), returnFunction)
	_threads.append(newThread)
	_windows.append([])
	_createDialogWindow(pos, newThread)


func _continueDialog(linkIndex : int, threadIndex : int, window : Control):
	if (linkIndex < 0):
		_closeThread(threadIndex)
		return
	
	_threads[threadIndex].continueDialog(linkIndex)
	_closeWindow(threadIndex, window)
	
	if (_threads[threadIndex].activePassage.keys().size() > 0):
		# we have a correct passage
		#var posn : Vector2 = Vector2(_threads[threadIndex].rootPosn.x + randf_range(_windowPosnVariance.x * -1, 
																					#_windowPosnVariance.x),
									#_threads[threadIndex].rootPosn.y + randf_range(_windowPosnVariance.y * -1, 
																					#_windowPosnVariance.y))
		_createDialogWindow(_threads[threadIndex].rootPosn, _threads[threadIndex])
	else:
		# empty dict, no more links, end dialog
		#_threads[threadIndex].returnFunction.call(_threads[threadIndex].thread)
		_closeThread(threadIndex)


#region Utility Functions
func _createDialogWindow(pos : Vector2, thread : DialogThread):
	var windowNode = _systemWindowScene.instantiate()
	var newDialog = windowNode.getCanvas()
	newDialog.loadWindow(pos, thread.getPassageText(), 
								thread.getSpeaker(), 
								thread.getLinks(), 
								thread.threadIndex)
	newDialog.DialogChoiceSelected.connect(_continueDialog)
	_windows[thread.threadIndex].append(newDialog)
	call_deferred("add_child", windowNode)


func _closeWindow(threadIndex : int, closeWindow : Control):
	_windows[threadIndex].erase(closeWindow)
	closeWindow.closeWindow()


func _closeThread(threadIndex : int):
	var closedThread : DialogThread = _threads[threadIndex]
	for window in _windows[threadIndex]:
		window.closeWindow()
	_threads.remove_at(threadIndex)
	_windows.remove_at(threadIndex)
	
	var count = 0
	for thread : DialogThread in _threads:
		thread.threadIndex = count
		for window in _windows[count]:
			window.changeThreadIndex(count)
		
		count += 1
	
	if (_threads.size() == 0):
		Settings.pauseGame(false)
	
	closedThread.completeThread()


func _clearDialog():
	pass
#endregion

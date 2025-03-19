extends Node2D

enum MenuState {MINIMIZED, PLAY, STATS}

@export_category("Object References")
@export var miniMenu : Node2D
@export var statMenu : Panel
@export var playMenu : Panel

var currentState : MenuState
var stateReference : Node

# Called when the node enters the scene tree for the first time.
func _ready():
	currentState = MenuState.MINIMIZED
	stateReference = miniMenu
	
	if miniMenu.implements.has(Interface.MenuState):
		miniMenu.stateMachine = self
	else:
		print("MENU DOES NOT IMPLEMENT MENUSTATE INTERFACE")
	
	if statMenu.implements.has(Interface.MenuState):
		statMenu.stateMachine = self
	else:
		print("MENU DOES NOT IMPLEMENT MENUSTATE INTERFACE")
	
	if playMenu.implements.has(Interface.MenuState):
		playMenu.stateMachine = self
	else:
		print("MENU DOES NOT IMPLEMENT MENUSTATE INTERFACE")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func handleInput(event : Enums.DeviceButton):
	sendInput(event)
#func _unhandled_input(event):
	#if Input.is_action_just_pressed("LeftButton"):
		#sendInput(Enums.InputType.LEFTBUTTON)
	#elif Input.is_action_just_pressed("MiddleButton"):
		#sendInput(Enums.InputType.MIDDLEBUTTON)
	#elif Input.is_action_just_pressed("RightButton"):
		#sendInput(Enums.InputType.RIGHTBUTTON)

func setState(state: MenuState):
	if (stateReference):
		stateReference.exitMenu()
	currentState = state
	
	match state:
		MenuState.MINIMIZED:
			stateReference = miniMenu
		MenuState.STATS:
			stateReference = statMenu
		MenuState.PLAY:
			stateReference = playMenu
	
	stateReference.initializeMenu()

func sendInput(input : Enums.DeviceButton):
	match currentState:
		MenuState.MINIMIZED:
			if miniMenu.implements.has(Interface.MenuState):
				miniMenu.takeInput(input)
		MenuState.PLAY:
			if playMenu.implements.has(Interface.MenuState):
				playMenu.takeInput(input)
		MenuState.STATS:
			if statMenu.implements.has(Interface.MenuState):
				statMenu.takeInput(input)

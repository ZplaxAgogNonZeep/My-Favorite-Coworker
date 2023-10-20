extends Node2D

enum MenuState {MINIMIZED, PLAY, STATS}

@export var miniMenu : Panel

var currentState : MenuState

# Called when the node enters the scene tree for the first time.
func _ready():
	currentState = MenuState.MINIMIZED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _unhandled_input(event):
	if Input.is_action_just_pressed("LeftButton"):
		sendInput(Enums.InputType.LEFTBUTTON)
	elif Input.is_action_just_pressed("MiddleButton"):
		sendInput(Enums.InputType.MIDDLEBUTTON)
	elif Input.is_action_just_pressed("RightButton"):
		sendInput(Enums.InputType.RIGHTBUTTON)


func sendInput(input : Enums.InputType):
	match currentState:
		MenuState.MINIMIZED:
			if miniMenu.implements.has(Interface.MenuState):
				miniMenu.takeInput(input)

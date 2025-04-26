extends Window

@export var _canvas : Control
@export var _windowType : Settings.SubWindowPositionType

func _ready() -> void:
	match Settings.windowAttentionMode:
		Settings.WindowAttentionOptions.ALWAYS_ON_TOP:
			always_on_top = true
		Settings.WindowAttentionOptions.BRING_TO_FRONT:
			always_on_top = false
		Settings.WindowAttentionOptions.DO_NOT_CHANGE:
			always_on_top = false


## Turns the window off and on again. Bypasses an unfixed bug in Godot where the window will crash
## if always_on_top is set while the window is open
func resetWindow():
	visible = false
	visible = true


func _visibilityChanged():
	if (visible):
		size = _canvas.size
		Settings.addToActiveWindows(self)
		position = Settings.findValidWindowPosition(_windowType, size)
	else:
		Settings.removeFromActiveWindows(self)
	

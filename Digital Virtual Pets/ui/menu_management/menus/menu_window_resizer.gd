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
	resetWindow()


## Turns the window off and on again. Bypasses an unfixed bug in Godot where the window will crash
## if always_on_top is set while the window is open
func resetWindow():
	visible = !visible
	visible = !visible


## Sets the size of the [
func setWindowToCanvasSize():
	if (Settings.gameScale >= 4):
		size = ceil(_canvas.size) * 2
		_canvas.scale = Vector2(2,2)
	else: 
		_canvas.scale = Vector2(1,1)
		size = ceil(_canvas.size)


func getCanvas():
	return _canvas


func _visibilityChanged():
	if (visible):
		setWindowToCanvasSize()
		Settings.addToActiveWindows(self)
		if (_windowType != Settings.SubWindowPositionType.DIALOG):
			position = Settings.findValidWindowPosition(_windowType, size)
		else:
			_canvas.setWindowPosition()
	else:
		Settings.removeFromActiveWindows(self)
	

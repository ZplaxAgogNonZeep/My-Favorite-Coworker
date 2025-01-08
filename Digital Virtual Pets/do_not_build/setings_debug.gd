extends Node

@export var _useOverrideSettings : bool

@export_category("Override Settings")
@export var _isUsingProactivity := true
@export var _proactivityTimeModifier := 0.50

func debugReady():
	if (_useOverrideSettings):
		Settings.isUsingProactivity = _isUsingProactivity
		Settings.proactivityTimeModifier = _proactivityTimeModifier

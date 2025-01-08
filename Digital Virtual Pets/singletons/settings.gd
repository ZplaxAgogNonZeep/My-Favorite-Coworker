extends Node

class_name settings

#region Global Variables
var windowFocused : bool = true
#endregion

#region Settings Variables
##  Bools
var isUsingProactivity := true
## Floats
var proactivityTimeModifier := 0.50
#endregion


#region Getter & Setter Functions

func setProactivity(isTrue : bool):
	isUsingProactivity = isTrue

#endregion

extends Node

signal PauseGame
signal UnpauseGame

#region Sound Events
signal PlaySoundEffect()
#endregion

#region System Events
signal DisplayDialog(pos : Vector2i, dialogResource : CharacterDialog, 
						conversationName : String, returnFunction : Callable)
signal OpenOptionsMenu
signal ToggleBorderlessMode(isBorderless : bool)
signal OpenDirectMenu(index : int)
signal ChangeCameraZoom(scale : float)
signal ChangeGameScale(scale : int)
signal CallToolTip(position : Vector2i, text : String)
signal DismissToolTip
#endregion

#region Timer Events
signal PauseTimers
signal UnpauseTimers
signal ResetAllTimers
signal TickHunger
signal TickJoy
signal ChangeProactivityMode()
#endregion

#region Pet Events
signal UnlockNewEgg(eggData : PetTypeData)
signal SpawnPetOnStart
signal ChangePet(index : int)
signal NewPetSpawned(isEgg : bool)
signal NewPetEvolved(isEgg : bool)
signal EvolveCheck
signal PetDied
signal ClearObjects
signal StartNeedsTimers
signal PetMoodChange(mood : ThoughtBubble.PetMood, time : float)

signal FeedPet
signal FoodPlaced(food)
signal Cry
#endregion

#region Device Events
signal DeviceRequestAttention
signal DeviceAttentionReceived
signal ShakeDeviceOnce
signal HopDeviceOnce

signal StartShakeDevice
signal EndShakeDevice
signal StartHopDevice
signal endHopDevice
signal FinishedShakeDevice
signal FinishedHopDevice
#endregion

#region VFX
signal PlayGameVFX(effect : VFXManager.VisualEffects, position : Vector2, 
					isFacingRight : bool, lifespan : float)
signal PlayDeviceVFX(effect : VFXManager.VisualEffects, position : Vector2, 
					isFacingRight : bool, lifespan : float)
#endregion

extends Node

signal PauseGame
signal UnpauseGame

#region Timer Events
signal PauseTimers
signal UnpauseTimers
signal ResetAllTimers
signal TickHunger
signal TickJoy
signal ChangeProactivityMode(isProactiveMode : bool)
#endregion

#region Pet Events
signal SpawnPetOnStart
signal NewPetSpawned(isEgg : bool)
signal NewPetEvolved(isEgg : bool)
signal EvolveCheck
signal PetDied
signal ClearObjects
signal StartNeedsTimers

signal FeedPet
signal FoodPlaced(food)
signal Cry
#endregion

#region Device Events
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

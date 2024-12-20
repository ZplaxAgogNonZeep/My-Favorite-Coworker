extends Node

signal PauseGame
signal UnpauseGame

#region Timer Events
signal PauseTimers
signal UnpauseTimers
signal ResetAllTimers
signal TickHunger
signal TickJoy
#endregion

#region Pet Events
signal SpawnPetOnStart
signal NewPetSpawned(isEgg : bool)
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

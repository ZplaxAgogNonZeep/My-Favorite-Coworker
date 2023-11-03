extends Node

signal PauseGame
signal UnpauseGame

# Timer Events
signal PauseTimers
signal UnpauseTimers
signal ResetAllTimers
signal TickHunger
signal TickJoy

# Pet Events
signal SpawnPetOnStart
signal NewPetSpawned
signal EvolveCheck
signal PetDied

signal FeedPet
signal FoodPlaced
signal Cry

# Device Events
signal ShakeDeviceOnce
signal HopDeviceOnce

signal StartShakeDevice
signal EndShakeDevice
signal StartHopDevice
signal endHopDevice

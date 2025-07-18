extends Node
##This is the global signal bus. It takes in signal emissions from anywhere in the project and can be accessed from anywhere in the project.
#Big thanks to this video for the idea and implementation
#https://youtu.be/excnQA86hW8?si=On6OjUtEn-2h2F2F

signal changeLevel(levelPath:String, spawnPosition:Vector2)
signal restartLevel
signal levelComplete
signal levelFailed

signal requestPlayerStateChange(state:Player.PlayerStates)

signal pauseGame
signal unpauseGame

signal exitToMenu

signal requestCameraFocus(focusRequester:Node2D)
signal returnCameraFocus()
signal requestCameraZoomChange(newZoom:float)

signal initiateDialogue(conversationArray:Array[DialogueConversation], conversationID:int, emittingNPC:NPC)

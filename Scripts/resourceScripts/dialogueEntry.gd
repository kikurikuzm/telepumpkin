class_name DialogueEntry extends Resource

@export_group("Dialogue Settings")
@export_multiline var dialogueText : String = "Enter text here!"
@export_enum("bald", "bovi", "cloak", "cool", "corpse", "inspect", "kid", "kin", "smoke") var dialoguePortrait: String
@export var textSpeed : float = 1.0
@export_group("Focus Settings")
@export var currentFocus : NodePath
@export var focusPlayer : bool = false
@export_group("Camera Settings")
@export var cameraSpeed : float = 0.1
@export var cameraZoom : float = 4.0
@export_group("Player Settings")
@export var playerCanMove : bool = false ##Whether or not the player should be able to move during the dialogue.
@export_group("Conversation Settings")
@export var goToNextConversation : bool = false ##Whether or not to increment the conversation array index by 1.
@export var manualNextConversation : int = 0 ##Desired conversation index. Leave at zero for no effect.

#if quickConvoVar.has("cameraSpeed"):
		#changeCameraSmoothingAmount.emit(quickConvoVar["cameraSpeed"])
	#if quickConvoVar.has("speed"):
		#textSpeed.wait_time = quickConvoVar["speed"]
	#if quickConvoVar.has("zoom"):
		#changeCameraZoom.emit(str_to_var(quickConvoVar["zoom"]))
	#if quickConvoVar.has("quest"):
		#questIndex = quickConvoVar["quest"]
	#if quickConvoVar.has("cutscene"):
		#var cutscene = quickConvoVar["cutscene"][0]
		#var playDuringDialogue = bool(quickConvoVar["cutscene"][1])
		#
	#if quickConvoVar.has("nextConvo"):
		#queueConvo(quickConvoVar["nextConvo"])
	#if quickConvoVar.has("canMove"):
		#pass
	#else:
		#changePlayerCharacterState.emit("playerBusy")
		##get_parent().get_parent().player.changeState("playerbusy")
	#if quickConvoVar.has("changeMyConvo"):
		#dialogueInitializer.convoID = quickConvoVar["changeMyConvo"]
	#if quickConvoVar["text"] == "":
		#dialogueBox.visible = false
		#dialogueText.visible_ratio = 1
	#if quickConvoVar["portrait"] == "":
		#dialoguePortrait.texture = Texture2D.new()

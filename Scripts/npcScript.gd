@tool
@icon("res://Resources/Editor Icons/npc.png")
class_name NPC extends Node2D

##An interactable level element that displays dialogue. Can be triggered.
##

@onready var animSprite:AnimatedSprite2D = $AnimatedSprite2D

@export_enum("bald", "bovi", "cloak", "cool", "corpse", "inspect", "kid", "kin", "smoke") var npcLook:String
@export var spriteFlip:bool
@export var conversationIndex:int ##The [DialogueConversation] to display upon interaction.
@export var dialogueArray:Array[DialogueConversation]

var canTalk = true

func _process(delta):
	if Engine.is_editor_hint():
		animSprite.flip_h = spriteFlip
		animSprite.play(npcLook)
		return

func _ready():
	animSprite.flip_h = spriteFlip
	animSprite.play(npcLook)
	
	for conversation in dialogueArray:
		for dialogue in conversation.conversationArray:
			if dialogue.currentFocus:
				dialogue.currentFocusAbsolutePath = get_node(dialogue.currentFocus).get_path()
			else:
				dialogue.currentFocusAbsolutePath = self.get_path()

func setConversationIndex(newIndex:int) -> void:
	conversationIndex = newIndex
 
func getConversationIndex() -> int:
	return conversationIndex

func NPCBeginConversation():
	GlobalSignalBus.initiateDialogue.emit(dialogueArray, conversationIndex, self)
	canTalk = false

func NPCFinishConversation():
	pass

func save() -> Dictionary:
	var saveDict = {
		"name" : name,
		"posX" : position.x,
		"posY" : position.y,
		"conversationIndex" : conversationIndex,
		"visible" : visible
	}
	return saveDict

func loadJSON(nodeData) -> void:
	conversationIndex = nodeData["conversationIndex"]
	visible = nodeData["visible"]

func _on_receive_trigger_notification(cause:Node2D) -> void:
	if canTalk:
		NPCBeginConversation()

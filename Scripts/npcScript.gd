@tool
@icon("res://Resources/Editor Icons/npc.png")
class_name NPC extends Node2D

##An interactable level element that displays dialogue. Can be triggered.
##

@onready var animSprite:AnimatedSprite2D = $AnimatedSprite2D
@onready var playerCheckArea:Area2D = $playerCheckArea
@onready var trigger:Trigger = $Trigger

@export var dialogueArray:Array[DialogueConversation]
@export_group("Appearance")
@export_enum("bald", "bovi", "cloak", "cool", "corpse", "inspect", "kid", "kin", "smoke", "science", "sign") var npcLook:String
@export var spriteFlip:bool = false
@export var facePlayer:bool = true
@export_group("Dialogue")
@export var conversationIndex:int ##The [DialogueConversation] to display upon interaction.
@export_group("Interaction")
@export var interactToInitiate:bool = true
@export var collideToInitiate:bool = false

var canTalk = true

func _process(delta):
	if Engine.is_editor_hint():
		animSprite.flip_h = spriteFlip
		animSprite.play(npcLook)
		return
	
	if playerCheckArea.has_overlapping_bodies() and facePlayer == true:
		for body in playerCheckArea.get_overlapping_bodies():
			if body is Player:
				if body.global_position > self.global_position:
					animSprite.flip_h = true
				elif body.global_position < self.global_position:
					animSprite.flip_h = false
				break
	else:
		animSprite.flip_h = spriteFlip

func _ready():
	animSprite.flip_h = spriteFlip
	animSprite.play(npcLook)
	
	if !interactToInitiate:
		trigger.disableTrigger()
	
	if collideToInitiate:
		trigger.enableTrigger()
		trigger.mustInteract = false
	
	for conversation in dialogueArray:
		for dialogue in conversation.conversationArray:
			if dialogue.currentFocus:
				dialogue.currentFocusAbsolutePath = get_node(dialogue.currentFocus).get_path()
			else:
				dialogue.currentFocusAbsolutePath = self.get_path()
			
			if dialogue.triggerToFire:
				dialogue.triggerAbsolutePath = get_node(dialogue.triggerToFire).get_path()

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

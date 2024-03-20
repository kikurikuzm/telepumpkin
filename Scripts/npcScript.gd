@tool
@icon("res://Resources/Editor Icons/npc.png")
extends Node2D
class_name NPC
##An interactable level element that displays dialogue. Can be triggered.
##
##Its trigger variable changes its position rather than initiating dialogue.

@onready var animSprite = get_node("AnimatedSprite2D")

@onready var dialogueManager = get_parent().get_node("dialogueManager")

@export_enum("bald", "bovi", "cloak", "cool", "corpse", "inspect", "kid", "kin", "smoke") var npcLook: String
@export var spriteFlip : bool
@export var convoID : int

var canTalk = true

func _process(delta):
	if Engine.is_editor_hint():
		animSprite.flip_h = spriteFlip
		animSprite.play(npcLook)
		return

func _ready():
	animSprite.flip_h = spriteFlip
	animSprite.play(npcLook)
	if not dialogueManager is DialogueManager:
		push_error("You must provide a dialogueManager node in the level for NPCs to function!")

func _input(event):
	if Input.is_action_just_pressed("teleport") and !dialogueManager.inDialogue:
		for i in $npcArea.get_overlapping_areas():
			if i.is_in_group("player"):
				print("started dialogue from NPC")
				dialogueManager.convoInitialize(convoID, self)
				canTalk = false
				break
		

func _on_npc_area_area_entered(area):
	if area.is_in_group("player"):
		canTalk = true

func save() -> Dictionary:
	var saveDict = {
		"name" : name,
		"posX" : position.x,
		"posY" : position.y,
		"convoID" : convoID,
		"visible" : visible
	}
	return saveDict

func loadJSON(nodeData) -> void:
	convoID = nodeData["convoID"]
	visible = nodeData["visible"]

func trigger(triggerChangePosition = null):
	if triggerChangePosition == null:
		dialogueManager.convoInitialize(convoID, self)
		canTalk = false
	else:
		global_position = Vector2(triggerChangePosition.posX, triggerChangePosition.posY)
		
	

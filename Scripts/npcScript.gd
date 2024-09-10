@tool
@icon("res://Resources/Editor Icons/npc.png")
class_name NPC extends Node2D

##An interactable level element that displays dialogue. Can be triggered.
##

@onready var animSprite = get_node("AnimatedSprite2D")

#@onready var dialogueManager = get_parent().get_node("dialogueManager")

@export_enum("bald", "bovi", "cloak", "cool", "corpse", "inspect", "kid", "kin", "smoke") var npcLook: String
@export var spriteFlip : bool
@export var convoID : int

var canTalk = true

signal initiateDialogue(conversationID, emittingNPCReference)

func _process(delta):
	if Engine.is_editor_hint():
		animSprite.flip_h = spriteFlip
		animSprite.play(npcLook)
		return

func _ready():
	animSprite.flip_h = spriteFlip
	animSprite.play(npcLook)

func _input(event):
	if Input.is_action_just_pressed("teleport") and canTalk:
		for i in $npcArea.get_overlapping_areas():
			if i.is_in_group("player"):
				print("found player and began dialogue")
				NPCBeginConversation()
				break

func NPCBeginConversation():
	print("begin conversation")
	initiateDialogue.emit(convoID, self)
	canTalk = false

func NPCFinishConversation():
	pass

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
		NPCBeginConversation()
	else:
		print(triggerChangePosition)
		#global_position = Vector2(triggerChangePosition[0], triggerChangePosition[1])

func _on_npc_area_area_entered(area):
	if area.is_in_group("player"):
		canTalk = true

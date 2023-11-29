@tool
extends Node2D

@onready var animSprite = get_node("AnimatedSprite2D")

@onready var dialogueManager = get_parent().get_node("dialogueManager")

@export var npcLook = "smoke"
@export var spriteFlip : bool
@export var convoID : int

var canTalk = true

func _process(delta):
	if Engine.is_editor_hint():
		animSprite.flip_h = spriteFlip
		animSprite.play(npcLook)

func _ready():
	animSprite.flip_h = spriteFlip
	animSprite.play(npcLook)
	if dialogueManager != DialogueManager:
		push_error("You must provide a dialogueManager node in the level for NPCs to function!")

func _input(event):
	if Input.is_action_just_pressed("teleport") and !dialogueManager.inDialogue and canTalk:
		for i in $npcArea.get_overlapping_areas():
			if i.is_in_group("player"):
				dialogueManager.convoInitialize(convoID)
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

func trigger():
	dialogueManager.convoInitialize(convoID)
	canTalk = false

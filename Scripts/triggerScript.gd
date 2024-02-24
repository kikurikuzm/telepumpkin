@tool
@icon("res://Resources/Editor Icons/trigger.png")

extends EditorElement
class_name Trigger

@onready var area2d = $Area2D

@export_category("Trigger Properties")
@export_group("Trigger Nodes")
@export var triggerList : Array ##A list of the nodes to trigger when this trigger is triggered.
@export var triggerListVariables : Array
@export var updateTriggerListVariables = false
@export_group("Trigger Settings")
@export var triggersOnce = true ##Whether or not the trigger will only trigger once.
@export var anythingTriggers = false ##Whether or not the trigger is triggered by any physics object (Pumpkins, TPP) or only the player.
@export var mustInteract = false ##Whether or not the player must press the interact button to trigger this trigger.
@export_group("Level Changing")
@export var sendLevel : PackedScene ##The scene to send the player to when this is triggered.
@export var spawnPosition = Vector2.ZERO 
@export var levelTransition = 0


var lastTriggerList


var hasTriggered = false ##Whether or not the trigger has already gone off.

#func _ready():
	#checkTriggerList()

func _process(delta):
	if updateTriggerListVariables == true:
		checkTriggerList()

func _input(event):
	if Input.is_action_just_pressed("teleport") and mustInteract:
		for node in area2d.get_overlapping_areas():
			if node.is_in_group("player"):
				triggerThings(node)

func triggerThings(cause) -> void:
	print(cause)
	if !hasTriggered:
		if anythingTriggers:
			var currentIndex = 0
			for i in triggerList:
				if triggerListVariables[currentIndex] != null:
					get_node(i).trigger(triggerListVariables)
				else:
					get_node(i).trigger()
				print("triggered ", str(i))
				if triggersOnce:
					hasTriggered = true
				currentIndex += 1
		if !anythingTriggers and cause.is_in_group("player"):
			var currentIndex = 0
			for i in triggerList:
				if triggerListVariables:
					if triggerListVariables[currentIndex] != null:
						get_node(i).trigger(triggerListVariables)
				else:
					get_node(i).trigger()
				print("triggered ", str(i))
				if triggersOnce:
					hasTriggered = true
		if sendLevel != null:
			get_parent().get_parent().loadLevel(sendLevel, levelTransition, spawnPosition)

func _on_area_2d_area_entered(area) -> void:
	if !mustInteract:
		triggerThings(area)

func save():
	var saveDict = {
		"name" : name,
		"posX" : position.x,
		"posY" : position.y,
		"triggered" : hasTriggered
	}
	return saveDict

func loadJSON(nodeData):
	hasTriggered = nodeData["triggered"]

func checkTriggerList():
	var currentIndex = 0
	for node in triggerList:
		if triggerList[currentIndex] == null:
			triggerListVariables[currentIndex] = null
		if node is NodePath:
			if get_node(node) is NPC:
				triggerListVariables.resize(triggerList.size())
				triggerListVariables[currentIndex] = {"posX" : 0, "posY" : 0}
		
		currentIndex += 1
	print("updated trigger variables")
	updateTriggerListVariables = false

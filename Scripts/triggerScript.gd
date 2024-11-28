@tool
@icon("res://Resources/Editor Icons/trigger.png")

extends EditorElement
class_name Trigger
##A level element that can activate other elements.

@onready var area2d : Area2D = $Area2D
@onready var interactIcon = $interactIcon

@export_category("Trigger Properties")
@export_group("Trigger Nodes")
@export var triggerList : Array[NodePath] ##A list of the nodes to trigger when this trigger is triggered.
@export var triggerListVariables : Array ##A way to trigger nodes and provide them with a variable upon triggering.
@export_tool_button("Update Trigger List Variables") 
var updateTriggerButton_action = checkTriggerList
@export_group("Trigger Settings")
@export var triggersOnce = true ##Whether or not the trigger will only trigger once.
@export var anythingTriggers = false ##Whether or not the trigger is triggered by any physics object (Pumpkins, TPP) or only the player.
@export var mustInteract = false ##Whether or not the player must press the interact button to trigger this trigger.
@export_group("Level Changing")
@export var desiredGotoLevel : PackedScene ##The scene to send the player to when this is triggered.
@export var desiredLevelSpawnPosition = Vector2.ZERO ##The position to spawn the player at when this is triggered.
@export var levelTransition = 0 ##What level transition to use upon changing level.

var sceneCutscenePlayer : CutscenePlayer

var lastTriggerList
var hasTriggered = false ##Whether or not the trigger has already gone off.

signal requestLevelChange(desiredLevelPath:String, desiredLevelPosition:Vector2)

func _ready():
	if !Engine.is_editor_hint():
		super._ready()
	if mustInteract:
		interactIcon.visible = true
	if get_parent().has_node("cutscenePlayer"):
		sceneCutscenePlayer = get_parent().get_node("cutscenePlayer")

#func _process(delta):
	#if updateTriggerListVariables == true:
		#checkTriggerList()

func _input(event):
	if Input.is_action_just_pressed("teleport") and mustInteract:
		for node in area2d.get_overlapping_areas():
			if node.is_in_group("player"):
				if node.get_parent().get_node("stateFactory").current_state != node.get_parent().get_node("stateFactory").states["playerbusy"]:
					if sceneCutscenePlayer:
						if !sceneCutscenePlayer.inCutscene:
							interactIcon.visible = false
							triggerThings(node)
					else:
						interactIcon.visible = false
						triggerThings(node)

## The main trigger function. Handles the triggering of its given objects and changing the level if applicable.
func triggerThings(cause) -> void:
	print(cause)
	if !hasTriggered:
		if anythingTriggers:
			var currentIndex = 0
			for i in triggerList:
				if triggerListVariables[currentIndex] != null:
					get_node(i).trigger(triggerListVariables[currentIndex])
				else:
					get_node(i).trigger()
				print("triggered ", str(i))
				if triggersOnce:
					hasTriggered = true
				currentIndex += 1
			if desiredGotoLevel != null:
				requestLevelChange.emit(desiredGotoLevel, desiredLevelSpawnPosition)
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
			if desiredGotoLevel != null:
				requestLevelChange.emit(desiredGotoLevel.resource_path, desiredLevelSpawnPosition)
				print_debug("emitted level change request with " + str(desiredGotoLevel.resource_path))

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
				if triggerListVariables[currentIndex] == null:
					triggerListVariables[currentIndex] = {"posX" : 0, "posY" : 0}
		
		currentIndex += 1
	print("updated trigger variables")
	#updateTriggerListVariables = false

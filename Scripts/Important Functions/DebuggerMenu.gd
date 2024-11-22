extends Node

@onready var debugConsoleTextInputReference = $PanelContainer/VBoxContainer/DebugCommandInput
@onready var debugOutputReference = $PanelContainer/VBoxContainer/DebugConsoleOutput

var debugPlayerFlyToggle = false
var debugLevelList : Array[String]

signal commandModifyPlayerState(desiredState:String)
signal commandChangeToLevelSignal(desiredLevelPath:String)
signal commandSkipCurrentCutscene
signal commandGetLevelList

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_menu"):
		if self.visible == false:
			self.visible = true
			debugConsoleTextInputReference.grab_focus()
		elif self.visible == true:
			self.visible = false

func interpretNewInput(newLine:String):
	debugConsoleTextInputReference.clear()
	
	var pastInputCommand = false
	var commandInputCommand : String = ""
	var commandInputArgument : String = ""
	
	for character in newLine:
		if character == " ":
			pastInputCommand = true
		
		if character != " " and character != "\n" and character != null:
			if !pastInputCommand:
				commandInputCommand += character
			elif pastInputCommand:
				commandInputArgument += character
			
	match commandInputCommand:
		"fly":
			commandTogglePlayerFly()
		"level":
			if !commandInputArgument.is_empty():
				if commandInputArgument == "list":
					for level in debugLevelList:
						writeToDebugConsole(level)
				else:
					commandChangeToLevel(commandInputArgument)
		"skip":
			commandSkipCurrentlyPlayingCutscene()

func writeToDebugConsole(stringToWrite:String):
	debugOutputReference.append_text("\n[color=lightgrey]" + stringToWrite)

func commandTogglePlayerFly():
	if debugPlayerFlyToggle:
		commandModifyPlayerState.emit("playerIdle")
		writeToDebugConsole("Disabled player flight")
		debugPlayerFlyToggle = false
	elif !debugPlayerFlyToggle:
		commandModifyPlayerState.emit("playerFly")
		writeToDebugConsole("Enabled player flight")
		debugPlayerFlyToggle = true

func commandChangeToLevel(desiredLevelPath:String):
	commandChangeToLevelSignal.emit("res://Levels/" + desiredLevelPath)
	writeToDebugConsole("Changing to level " + desiredLevelPath)

func commandSkipCurrentlyPlayingCutscene():
	commandSkipCurrentCutscene.emit()
	writeToDebugConsole("Skipped currently playing cutscene")

func _debugInputCommandSubmitted(new_text: String) -> void:
	interpretNewInput(new_text)

func _parseErrorMessage(errorMessage: String) -> void:
	writeToDebugConsole(errorMessage)

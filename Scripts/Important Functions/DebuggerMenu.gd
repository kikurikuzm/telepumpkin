extends Node

@onready var debugConsoleTextInputReference = $PanelContainer/VBoxContainer/DebugCommandInput
@onready var debugOutputReference = $PanelContainer/VBoxContainer/DebugConsoleOutput

var debugPlayerFlyToggle = false

signal commandModifyPlayerState(desiredState:String)
signal commandChangeToLevelSignal(desiredLevelPath:String)
signal commandCreateNewInstanceSignal(desiredInstance:String)
signal commandSkipCurrentCutscene

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_menu"):
		if self.visible == false:
			self.visible = true
			debugConsoleTextInputReference.clear()
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
		"lev":
			commandChangeToLevel(commandInputArgument)
		"spawn":
			commandCreateNewInstance(commandInputArgument)
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
	commandChangeToLevelSignal.emit(desiredLevelPath)
	writeToDebugConsole("Changing to level " + desiredLevelPath)

func commandCreateNewInstance(desiredInstance:String):
	commandCreateNewInstanceSignal.emit(desiredInstance)
	writeToDebugConsole("Creating a new instance of " + desiredInstance)

func commandSkipCurrentlyPlayingCutscene():
	commandSkipCurrentCutscene.emit()
	writeToDebugConsole("Skipped currently playing cutscene")

func _debugInputCommandSubmitted(new_text: String) -> void:
	interpretNewInput(new_text)

extends Node
class_name CutsceneManager

@export var cutsceneJSONPath = "JSON FILEPATH HERE"

var currentCutscene = 0

var cutscene : Array

func parseJSON() -> Array:
	var f = FileAccess.open(cutsceneJSONPath, FileAccess.READ)
	var json = f.get_as_text()
	
	var output = JSON.parse_string(json)
	if typeof(output) == TYPE_ARRAY:
		return output
	else:
		return []

func startCutscene(cutsceneID:int):
	cutscene = parseJSON()
	currentCutscene = cutsceneID
	cutsceneProcess()

func cutsceneProcess():
	print(cutscene[0]["cutscene"][1]["event"][0]["character"])

func trigger():
	startCutscene(0)

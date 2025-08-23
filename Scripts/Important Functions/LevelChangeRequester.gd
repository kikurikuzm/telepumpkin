class_name LevelChangeRequester extends Node

@export_file("*_lev.tscn") var level : String ##The scene to send the player to when this is triggered.
@export var spawnPosition:Vector2 = Vector2.ZERO ##Where to spawn the player in the given level. If left at [member Vector2.ZERO], the default spawnpoint will take precedence.
@export_enum("Specific Level","Fail","Success","Restart") var levelChangeType:int = 0 ##What this [LevelChangeRequester]'s request should be considered.
#@export var levelTransition:int = 0 ##What level transition to use upon changing level.

enum LevelChangeTypes {
	FAIL,
	SUCCESS,
	RESTART,
	SPECIFIC_LEVEL
}

func setLevelChangeType(newType:LevelChangeTypes) -> void:
	levelChangeType = newType

func getLevelChangeType() -> LevelChangeTypes:
	return levelChangeType

func setGotoLevel(levelFilePath:String) -> void:
	level = levelFilePath

func getGotoLevel() -> String:
	return level

func setGotoLevelSpawnPosition(newSpawnPosition:Vector2) -> void:
	spawnPosition = newSpawnPosition

func getGotoLevelSpawnPosition() -> Vector2:
	return spawnPosition

func changeLevel() -> void: ##Makes a level request based on [param levelChangeType].
	match levelChangeType:
		LevelChangeTypes.FAIL:
			GlobalSignalBus.levelFailed.emit()
			
		LevelChangeTypes.SUCCESS:
			GlobalSignalBus.levelComplete.emit()
			
		LevelChangeTypes.RESTART:
			GlobalSignalBus.restartLevel.emit()
			
		LevelChangeTypes.SPECIFIC_LEVEL:
			if level:
				print_debug("changing level to %s " % level)
				print_debug("with spawnpos at %s " % str(spawnPosition))
				GlobalSignalBus.changeLevel.emit(level, spawnPosition)

func _on_receive_trigger_notification(cause:Node2D) -> void:
	changeLevel()

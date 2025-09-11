class_name LevelChangeRequester extends Node

@export_file("*_lev.tscn") var level : String = "" ##The scene to send the player to when this is triggered.
@export var spawnPosition:Vector2 = Vector2.ZERO ##Where to spawn the player in the given level. If left at [member Vector2.ZERO], the default spawnpoint will take precedence.
@export_enum("Fail","Success","Restart","Specific Level",) var levelChangeType:int = 0 ##What this [LevelChangeRequester]'s request should be considered.
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

func changeLevel(newLevelChangeType:LevelChangeTypes = -1) -> void: ##Makes a level request based on [param levelChangeType].
	if newLevelChangeType != -1:
		levelChangeType = newLevelChangeType as int
	print_debug("Tried changing level: %d" % levelChangeType)
	match levelChangeType as LevelChangeTypes:
		LevelChangeTypes.FAIL:
			print_debug("level fail")
			GlobalSignalBus.levelFailed.emit()
			
		LevelChangeTypes.SUCCESS:
			print_debug("Success emitted")
			GlobalSignalBus.levelComplete.emit()
			
		LevelChangeTypes.RESTART:
			print_debug("level restart")
			GlobalSignalBus.restartLevel.emit()
			
		LevelChangeTypes.SPECIFIC_LEVEL:
			print_debug("level specific")
			if !level.is_empty():
				print_debug("changing level to %s " % level)
				print_debug("with spawnpos at %s " % str(spawnPosition))
				GlobalSignalBus.changeLevel.emit(level, spawnPosition)

func _on_receive_trigger_notification(cause:Node2D) -> void:
	changeLevel(levelChangeType)

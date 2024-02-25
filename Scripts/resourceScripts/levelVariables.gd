extends Resource
class_name LevelVariables

@export_category("Level Variables")

@export_group("Player-Related")
@export var canTeleport = true
@export_subgroup("View")
@export var playerZoom = 4.5
@export var hasVignette = false
@export var hasMapView = true
@export var startsInMap = false
@export var mapCameraLocked = true


@export_group("Level-Related")
@export var levelAmbience : AudioStream
@export var levelTransition = 1
@export var levelMusic : AudioStream
@export var musicChance = 0.2
@export var levelGravity = 9.8
@export_subgroup("Appearance")
@export var isDark = false
@export var levelBackground : Texture2D
@export var levelForeground : Texture2D
@export var worldEnvironment : Environment

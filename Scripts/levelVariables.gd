extends Node

@export var levelVariables: LevelVariables

var canTeleport = true
var playerZoom = 4.5
var hasVignette = false
var hasMapView = true
var startsInMap = false
var mapCameraLocked = true

var levelAmbience : AudioStream
var levelTransition = 1
var levelMusic : AudioStream
var musicChance = 0.2
var isDark = false
var levelBackground : Texture2D
var levelForeground : Texture2D
var worldEnvironment : Environment
var levelGravity = 9.8

func _ready():
	canTeleport = levelVariables.canTeleport
	playerZoom = levelVariables.playerZoom
	hasVignette = levelVariables.hasVignette
	hasMapView = levelVariables.hasMapView
	startsInMap = levelVariables.startsInMap
	mapCameraLocked = levelVariables.mapCameraLocked
	levelAmbience = levelVariables.levelAmbience
	levelTransition = levelVariables.levelTransition
	levelBackground = levelVariables.levelBackground
	levelForeground = levelVariables.levelForeground
	worldEnvironment = levelVariables.worldEnvironment
	isDark = levelVariables.isDark
	levelMusic = levelVariables.levelMusic
	musicChance = levelVariables.musicChance
	levelGravity = levelVariables.levelGravity

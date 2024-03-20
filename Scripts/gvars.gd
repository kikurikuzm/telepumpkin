extends Node

var pCollected = 0
var pMax = 0

var playerGravity = 9.8

var inDialogue = false

var maxTeleports = 0
var currentTPs = 0

var zoomOutScale = 1

var onFloor = false

var mousefly = false

signal pumpkinCollected()
signal levelFinish()
signal debugLChange(level)

var versionNum = "0.7.0"

var prevScene
var prevLoc = Vector2.ZERO

var customLoad = null

var simpleGraphics = false

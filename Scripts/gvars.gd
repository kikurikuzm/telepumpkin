extends Node

var pCollected = 0
var pMax = 0

var maxTeleports = 0
var currentTPs = 0

var zoomOutScale = 1

var onFloor = false

var mousefly = false

signal pumpkinCollected()
signal levelFinish()
signal debugLChange(level)

var versionNum = "Beta 0.6.0/testing"

var prevScene
var prevLoc = Vector2.ZERO

var customLoad = null

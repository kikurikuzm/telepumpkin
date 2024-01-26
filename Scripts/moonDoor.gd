@tool
extends Node2D

@export var locked = false
@export var flipped = false

@onready var staticBody = $StaticBody2D
@onready var area = $Area2D
@onready var animationPlayer = $AnimationPlayer
@onready var lightOccluder = $maindoor/frame/frame/LightOccluder2D
@onready var doorLight = $maindoor/frame/FrameFront/PointLight2D

@onready var delayTimer = $delayTimer
@onready var beepTimer = $beepTimer
@onready var audioStream = $doorSFX
@onready var beepAudioStream = $beep

var openOGG = preload("res://Audio/sfx/moonDoorOpen.ogg")
var closeOGG = preload("res://Audio/sfx/moonDoorClose.ogg")

var beepOpen = preload("res://Audio/sfx/doorBeepOpen.ogg")
var beepClose = preload("res://Audio/sfx/doorBeepClose.ogg")

var isOpen = true
	
func _process(delta):
	if flipped:
		scale.x = -1
	else:
		scale.x = 1
	
	if locked:
		isOpen = false
		doorLight.color = Color("ff170d")
	
	if !Engine.is_editor_hint():
		if Input.is_action_just_pressed("teleport"):
			for i in area.get_overlapping_bodies():
				if i.is_in_group("player"):
					if delayTimer.is_stopped() and !locked:
						if isOpen:
							beepAudioStream.stream = beepOpen
							beepAudioStream.play()
							doorLight.color = Color("ff170d")
							
							beepTimer.start()
							await(beepTimer.timeout)
							audioStream.stream = openOGG
							audioStream.play()
							staticBody.process_mode = Node.PROCESS_MODE_DISABLED
							animationPlayer.play("doorOpen")
							lightOccluder.occluder_light_mask = 20
							isOpen = false
							delayTimer.start(0.1)
							return
						if !isOpen:
							beepAudioStream.stream = beepClose
							beepAudioStream.play()
							doorLight.color = Color("66ffe3")
							
							beepTimer.start()
							await(beepTimer.timeout)
							audioStream.stream = closeOGG
							audioStream.play()
							staticBody.process_mode = Node.PROCESS_MODE_INHERIT
							animationPlayer.play("doorClose")
							lightOccluder.occluder_light_mask = 1
							isOpen = true
							delayTimer.start(0.1)
			

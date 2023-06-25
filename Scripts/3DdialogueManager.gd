extends Node3D

@onready var dialogueLabel = get_parent().get_node("SubViewport/dialogue")
@onready var dialogueTimer = $dialogueTimer
@onready var fadeTimer = $fade

var reading = true

func _process(delta):
	while reading and dialogueLabel.visible_ratio < 1.5 and dialogueTimer.is_stopped():
		dialogueLabel.visible_ratio += 0.05
		dialogueTimer.start(0.05)
		await dialogueTimer.timeout
	
	if dialogueLabel.visible_ratio == 1:
		reading = false

	if reading == false and fadeTimer.is_stopped():
		fadeTimer.start(1)
		await fadeTimer.timeout
		dialogueLabel.modulate = lerp(dialogueLabel.modulate, Color(1, 0.25, 0.25, 0), 0.2)
		
func sendDialogue(text:String):
	dialogueLabel.text = text
	reading = true
	dialogueLabel.modulate = Color(1,1,1,1)

extends CanvasLayer

@onready var colorRect = get_node("ColorRect")
@onready var animationPlayer = get_node("AnimationPlayer")

signal fadedIn
signal fadedOut

signal wipedIn
signal wipedOut

func _ready():
	visible = true
	fadeEnd()

func fadeStart():
	animationPlayer.play("fadeStart")
	fadedIn.emit()

func fadeEnd():
	animationPlayer.play("fadeEnd")
	fadedOut.emit()

func wipeStart():
	animationPlayer.play("wipeStart")
	wipedIn.emit()
	
func wipeEnd():
	animationPlayer.play("wipeEnd")
	wipedOut.emit()

func playTransition(animationName):
	animationPlayer.play(animationName)

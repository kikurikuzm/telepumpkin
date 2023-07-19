extends Node2D

@onready var animSprite = get_node("AnimatedSprite2D")

@onready var dialogueManager = get_parent().get_node("dialogueManager")

@export var npcLook = "smoke"
@export var spriteFlip : bool
@export var convoID : int

var canTalk = true

var dialogArray = [
 ["Another one, huh?", "You know, the only organic things we get down here are rejects from that farm above."],
 ["You hear about the sewer?", "Not knowing what else could be down there gives me the creeps.."],
 ["Yea, tell me about it.", "I certainly hope whatever poor sap finds themself down there can make it out."],
 ["Man, I wish I could go to the moon...", "Just to know what was up there."],
 ["I see you're interested in this moon trip.", "Lucky for you, I have one last economy ticket.", "$5 is the price, and this deal won't last forever.", "So get to it! Bring me that $5, and you'll be on your way to the moon in no time."],
 ["Hello there.", "Are you lost? Or are you looking for a room?", "...A room costs $10, if thats what you're after."],
 ["Go away. Can't you see I'm busy?"],
 ["Ah, I see you've gathered the funds.", "Here, just give me a minute..."],
 ["Hey, you.", "You need cash, yea?", "Well I need a thing retrieved for me.", "I'll spare you the backstory, but it's currently down in the sewers.", "Here, come with me."],
 ["Alright, head down there. I'll see you on the flipside."],
 [""],
 ["Are you aware of all the knowledge that books contain?", "All these books have answers. Even for you."],
 ["There is much learning to be done here.", "At your leisure, of course.", "Do too much reading and you might start seeing meaning in meaningless things."],
 ["Oh, you aren't the person I was waiting for, are you."],
 ["There appears to be nothing here."],
 ["The one book you can reach is titled: \"The Knowledge of the Universe\".", "All the pages are ripped out."]
]

func _ready():
	animSprite.flip_h = spriteFlip
	animSprite.play(npcLook)

func _input(event):
	if Input.is_action_just_pressed("teleport") and !dialogueManager.inDialogue and canTalk:
		for i in $npcArea.get_overlapping_areas():
			if i.is_in_group("player"):
				dialogueManager.convoInitialize(convoID)
				canTalk = false
				break
		

func _on_npc_area_area_entered(area):
	if area.is_in_group("player"):
		canTalk = true

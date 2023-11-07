extends Node2D

@onready var writingSFX = preload("res://Audio/sfx/632476__ani_music__pencil-writing-on-paper-7-strokes.wav")

var questID : int

func questModify():
	match questID:
		1:
			#bovi dissapear
			var scenePath = "res://Levels/apartments.tscn"
			var scene = load(scenePath)
			var root = scene.instantiate()
			for node in root.get_children():
				if node.name == "entrance2":
					node.scene = null
			scene.pack(root)
			ResourceSaver.save(scene, scenePath)
			
		2:
			#changes guy to bring you to sewer intro, triggered after talking to the cloak guy
			NPCsaveConvo("NPC2", "apartments.tscn", 2)
			NPCsaveConvo("NPC5", "moonCity.tscn", 2)
			get_parent().currentLevel.get_node("NPC5").convoID = 2
		3:
			#changes apartments guy to take back the tpp, triggered after he finishes his sewerintro dialogue 
			get_parent().currentLevel.get_node("NPC2").convoID = 3
			NPCsaveConvo("NPC2", "apartments.tscn", 3)
			get_parent().loadLevel(load("res://Levels/sewerIntro.tscn"),2)
		4:
			get_parent().loadLevel(load("res://Levels/Level5.tscn"),2)
			questSFX()
		5:
			get_parent().player.hasTPP = false
			get_parent().player.holdingTPP = false
		6:
			NPCsaveConvo("NPC1", "sewerOutro.tscn", 1)
			get_parent().currentLevel.get_node("NPC1").convoID = 1
			
func changeQuest(id):
	if id > questID:
		questID = id
		print("changed quest to ", id)
		questModify()

func questSFX():
	var tempPlayer = AudioStreamPlayer.new()
	get_parent().add_child(tempPlayer)
	tempPlayer.stream = writingSFX
	tempPlayer.pitch_scale = randf_range(0.85, 1.10)
	tempPlayer.volume_db = -10.0
	tempPlayer.play()
	await tempPlayer.finished
	tempPlayer.queue_free()

func NPCsaveConvo(npcName:String, level:String, convoID:int):
	var levelSave = FileAccess.open(str("user://levelSaves/", str(level), ".lsav"), FileAccess.WRITE)
	
	var saveData = {
		"name" : npcName,
		"posX" : position.x,
		"posY" : position.y,
		"convoID" : convoID
	}
	var jsonString = JSON.stringify(saveData)
	
	levelSave.store_line(jsonString)

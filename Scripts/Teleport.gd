extends Sprite2D

@onready var teleTimer = get_node("teleport")
@onready var teleArea = get_node("Area2D")

func _process(delta):
	if teleArea.get_overlapping_bodies().size() > 0 and teleTimer.is_stopped():
		#getting all the physics bodies within the teleport range
		var selected = teleArea.get_overlapping_bodies()
		
		var availablePumpkins = []
		
		for node in selected:
			if node.is_in_group("pumpkin") and !availablePumpkins.has(node):
				availablePumpkins.append(node)
				node.highlighted = false
		
		if len(availablePumpkins) > 0:
			var nearestPumpkin = availablePumpkins[0]
		
			for pumpkin in availablePumpkins:
				if pumpkin.global_position.distance_to(self.global_position) > nearestPumpkin.global_position.distance_to(self.global_position):
					nearestPumpkin = pumpkin
				
			nearestPumpkin.highlighted = true


func rangeTeleport(teleportPos:Transform2D) -> void:
	if teleArea.get_overlapping_bodies().size() > 0 and teleTimer.is_stopped():
		#getting all the physics bodies within the teleport range
		var selected = teleArea.get_overlapping_bodies()
		
		var availablePumpkins = []
		
		var failCount = 0
		
		for node in selected:
			if node.is_in_group("pumpkin") and !availablePumpkins.has(node):
				availablePumpkins.append(node)
		
		if len(availablePumpkins) > 0:
			var nearestPumpkin = availablePumpkins[0]
		
			for pumpkin in availablePumpkins:
				if pumpkin.global_position.distance_to(self.global_position) > nearestPumpkin.global_position.distance_to(self.global_position):
					nearestPumpkin = pumpkin
				else:
					failCount += 1
					
			if failCount == len(availablePumpkins):
			#print("already had closest")
				teleportMove(teleportPos, nearestPumpkin)
			else:
			#print("teleported new nearest")
				teleportMove(teleportPos, nearestPumpkin)
	
func teleportMove(teleportPos:Transform2D, pumpkin):
	pumpkin.teleport(teleportPos)
	pumpkin.translate(Vector2(0, -15))
	$teleportAudio.pitch_scale = randf_range(0.8, 1.2)
	$teleportAudio.play()
	teleTimer.start()
	return


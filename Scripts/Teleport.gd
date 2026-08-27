class_name TeleportRange extends Sprite2D

@onready var teleTimer: Timer = $teleport
@onready var teleArea: Area2D = $Area2D
@onready var teleportCast: ShapeCast2D = $teleportCheckCast

var selectedPumpkin : Node2D
var scaleOverridden = false

var objectsPendingTeleportCommit: Array[Node2D] = []

var canHighlightTargets:bool = true

var cannotTeleportOverride:bool = false

const TELEPORT_COOLDOWN : float = 0.7
const KICKBACK_MOD : float = 1.1

const HORIZONTAL_STRETCH_SCALE : Vector2 = Vector2(3.0, 0.9)
const VERTICAL_STRETCH_SCALE : Vector2 = Vector2(0.9, 3.5)
const BOTH_STRETCH_SCALE : Vector2 = Vector2(2.0, 2.0)
const NONE_STRETCH_SCALE : Vector2 = Vector2(1.0, 1.0)

func _process(delta):
	selectedPumpkin = null
	
	self.modulate = lerp(self.modulate, Color(1.0, 1.0, 1.0, 0.05), 0.1)
	
	if !scaleOverridden:
		scale.x = lerp(scale.x, 1.5, 0.07)
		scale.y = lerp(scale.y, 1.5, 0.07)
	
	if cannotTeleportOverride == true: return
	
	#if teleportCast.get_collision_count()
	if teleArea.get_overlapping_bodies().size() > 0 and teleTimer.is_stopped():
		#getting all the physics bodies within the teleport range
		var selected = teleArea.get_overlapping_bodies()
		
		var availablePumpkins = []
		
		for node in selected:
			if node is TeleportableObject and !availablePumpkins.has(node):
		#adding all the pumpkins to availablePumpkins if not already added
		#and making them not highlighted
				availablePumpkins.append(node)
				node.highlighted = false
		
		if len(availablePumpkins) > 0 and visible and canHighlightTargets == true:
			var farthestPumpkin = availablePumpkins[0]
		#changing the nearest pumpkin to be the first one in the list
		#if the list contains anything
			for pumpkin in availablePumpkins:
				if pumpkin.global_position.distance_to(self.global_position) > farthestPumpkin.global_position.distance_to(self.global_position):
					farthestPumpkin = pumpkin
				#going over availablePumpkins and seeing if there are any farther than the current one
				#and highlighting the selected one
				
			farthestPumpkin.highlighted = true
			selectedPumpkin = farthestPumpkin
			self.modulate = lerp(self.modulate, Color(1.0, 1.0, 1.0, 0.6), 0.14)


func setScale(rangeScale:Vector2) -> void:
	pass


func setCanHighlight(canHighlight:bool) -> void:
	self.canHighlightTargets = canHighlight


func getCanHighlight() -> bool:
	return self.canHighlightTargets


func canTeleport() -> bool:
	if !self.rangeHasTeleportTargets(): return false
	elif !teleTimer.is_stopped(): return false
	else: return true


func rangeHasTeleportTargets() -> bool:
	var targetReference:Node2D = null
	for body in teleArea.get_overlapping_bodies():
		if body is TeleportableObject:
			targetReference = body
			break
	
	if targetReference != null and cannotTeleportOverride == false: return true
	else: return false


func rangeHasPlayer() -> bool:
	var foundPlayer:bool = false
	for body in teleArea.get_overlapping_bodies():
		if body is Player:
			foundPlayer = true
			break
		
	return foundPlayer


func rangeTeleport(teleportPos:Vector2, teleportVelocity:Vector2) -> Array:
	if teleArea.get_overlapping_bodies().size() <= 0 or !teleTimer.is_stopped() or cannotTeleportOverride == true: return [Vector2.ZERO, Vector2.ZERO]
	
	#getting all the physics bodies within the teleport range
	var selected = teleArea.get_overlapping_bodies()
	
	var availablePumpkins = []
	
	var failCount = 0
	
	for node in selected:
		if node is TeleportableObject and !availablePumpkins.has(node):
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
			return teleportMove(teleportPos, teleportVelocity, nearestPumpkin)
		else:
		#print("teleported new nearest")
			return teleportMove(teleportPos, teleportVelocity, nearestPumpkin)
		
	return [Vector2.ZERO, Vector2.ZERO]


func teleportMove(teleportPos:Vector2, teleportVelocity:Vector2, teleportableObject:TeleportableObject) -> Array:
	var pumpkinPosition:Vector2 = teleportableObject.global_position
	var kickbackVelocity:Vector2 = teleportPos - pumpkinPosition # A directional impulse against the player as a result of teleportation. 
	kickbackVelocity *= KICKBACK_MOD
	
	var teleportChanges: Array = teleportableObject.teleport(teleportPos, teleportVelocity)
	var highestTeleportPosition: Vector2 = teleportChanges[0]
	objectsPendingTeleportCommit = teleportChanges[1]
	
	return [kickbackVelocity, highestTeleportPosition]


func commitTeleport() -> void:
	for object: TeleportableObject in objectsPendingTeleportCommit:
		object.applyPendingTransforms()
	
	objectsPendingTeleportCommit.clear()
	
	$teleportAudio.pitch_scale = randf_range(0.8, 1.2)
	$teleportAudio.play()
	teleTimer.start(TELEPORT_COOLDOWN)

func discardTeleport() -> void:
	for object: TeleportableObject in objectsPendingTeleportCommit:
		object.discardPendingTransforms()
	
	objectsPendingTeleportCommit.clear()

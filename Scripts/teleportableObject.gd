class_name TeleportableObject extends CharacterBody2D

var poofs:PackedScene = preload("res://Instances/Particles/poofs.tscn")
var teleportNumber:PackedScene = preload("res://Instances/teleportsRemainingNumber.tscn")
var teleportLight:PackedScene = preload("res://Instances/Particles/teleport_light.tscn")
var raycast:PackedScene = preload("res://Instances/Helpers/pumpkinRay.tscn")

@export_group("Physics Properties")
@export var physicsProperties:PhysicsMaterial

@export_group("Pumpkin Properties")
@export var rotting:bool = false
@export var rottingTeleport:int = 0

@onready var animationPlayer = $AnimationPlayer
@onready var sprite = $pumpkinSprite
@onready var pumpkinDetectArea: Area2D = $pumpkinDetectArea

var highlighted:bool = false
var highlightDistortion : float = 0.0

var bounceCount:int = 0

var newPosition:Vector2
var newVelocity:Vector2

var lastFrameVelocity:Vector2 = Vector2.ZERO

var gravity:float = 0.0
var originalGravity:float = ProjectSettings.get_setting("physics/2d/default_gravity")

var shaderDistortionAmount:float = 0

const TELEPORT_VELOCITY_DECAY:Vector2 = Vector2(0.1, 0.5)
const TELEPORT_VELOCITY_BUMP:Vector2 = Vector2(0, -120)

const MIN_VELOCITY_CUTOFF:float = 5.0

const SHADER_MAX_DISTORTION:float = 0.16
const SHADER_ROTTING_MAX_DISTORTION:float = 0.01

func _ready():
	sprite.material.set_shader_parameter("distortion_strength", 0.0)
	if rotting == true:
		shaderDistortionAmount = SHADER_ROTTING_MAX_DISTORTION
		sprite.animation = "rotting"
	else:
		shaderDistortionAmount = SHADER_MAX_DISTORTION
		sprite.animation = "normal"

func _physics_process(delta):
	if self.is_on_wall_only():
		if abs(lastFrameVelocity.x) - abs(self.velocity.x) > 5.0:
			self.velocity.x -= floorf(lastFrameVelocity.x * physicsProperties.bounce * 0.25)
			
			if self.velocity.x < 0: 
				animationPlayer.play("bounce_wall_right")
			elif self.velocity.x > 0:
				animationPlayer.play("bounce_wall_left")
	
	if self.is_on_floor(): 
		if abs(lastFrameVelocity.y) - abs(self.velocity.y) > 5.0:
			self.velocity.y -= floorf(lastFrameVelocity.y * physicsProperties.bounce)
		
		if self.velocity.y < -8.0:
			print_debug(self.velocity.y)
			var blendAmount:float = clampf(abs(self.velocity.y), 0.0, 1.0)
			#print_debug( self.velocity.y )
			animationPlayer.stop()
			animationPlayer.play("bounce_floor", 0.01)
		
		if abs(self.velocity.x) > MIN_VELOCITY_CUTOFF:
			self.velocity.x += (sqrt(abs(self.velocity.x)) * physicsProperties.friction) * -1 * signf(self.velocity.x)
		else: 
			self.velocity.x = 0
	else:
		lastFrameVelocity = floor(velocity)
		self.velocity.y += self.get_gravity().y * 0.5 * delta
		
		#gravity = gravity + (gravity*1.05)*0.1
		#lastFrameVelocity.y -= gravity * 0.5 * delta
		#lastFrameVelocity.y += originalGravity
	
	if abs(self.velocity) > Vector2(200, 200):
		#print_debug(self.velocity)
		self.velocity.y = clampf(self.velocity.y, -200, 200) # hopefully avoids sending the player into space/the void
	
	self.velocity.x += self.get_gravity().x * delta
	
	self.velocity.x = clampf(self.velocity.x, -300, 300)
	#lastFrameVelocity = lastFrameVelocity * physicsProperties.bounce
	
	self.move_and_slide()

func _process(delta):
	if rotting:
		if rottingTeleport > 4:
			sprite.frame = 0
		else:
			match rottingTeleport:
				0:
					sprite.frame = 4
				1:
					sprite.frame = 3
				2:
					sprite.frame = 2
				3:
					sprite.frame = 1
				4:
					sprite.frame = 0

	
	if highlighted:
		highlightDistortion = lerp(highlightDistortion, shaderDistortionAmount, 0.1)
		sprite.material.set_shader_parameter("distortion_strength", highlightDistortion)
		$selectParticles.emitting = true
		
	else:
		highlightDistortion = lerp(highlightDistortion, 0.0, 0.02)
		sprite.material.set_shader_parameter("distortion_strength", highlightDistortion)
		$selectParticles.emitting = false
		
	highlighted = false

func setVelocity(newVelocity:Vector2) -> void:
	lastFrameVelocity = newVelocity
	self.velocity = newVelocity

func getVelocity():
	return velocity
	
func traverseManhole(exitPos: Vector2, exitVel: Vector2):
	self.position = exitPos
	self.velocity = exitVel

func teleport(destination:Vector2, inheritedVelocity:Vector2, bringNearbyObjects: bool = true) -> Vector2:
	self.velocity = Vector2.ZERO
	var highestPosition: Vector2 = destination
	highestPosition.y -= $CollisionShape2D.shape.get_rect().size.y / 2
	
	if bringNearbyObjects:
		for overlappingArea in pumpkinDetectArea.get_overlapping_areas():
			if overlappingArea.get_parent() is TeleportableObject:
				var accompanyingObject: TeleportableObject = overlappingArea.get_parent() # an object that should be teleported alongside the pumpkin
				var positionDifference: Vector2 = self.global_position - accompanyingObject.global_position + Vector2(0, 4)
				if positionDifference.y > 0:
					accompanyingObject.velocity.y = 0
					highestPosition = accompanyingObject.teleport(destination - positionDifference, inheritedVelocity * 0.25, true)
	
	
	newPosition = destination
	newVelocity = inheritedVelocity
	
	velocity.x += inheritedVelocity.x
	velocity *= TELEPORT_VELOCITY_DECAY
	velocity += TELEPORT_VELOCITY_BUMP
		
	var oldPos:Vector2 = self.global_position
	
	#await get_tree().physics_frame
	self.global_position = newPosition
	
	var poofInstance:Node2D = poofs.instantiate()
	poofInstance.hide()
	get_tree().root.add_child(poofInstance)
	poofInstance.global_position = oldPos
	spawnTracer(oldPos)
	poofInstance.show()
	
	animationPlayer.play("teleport")
	#animationPlayer.queue("idle")
	
	if rotting:
		var numberInstance = teleportNumber.instantiate()
		get_parent().add_child(numberInstance)
		numberInstance.global_position = oldPos
		numberInstance.teleportsRemaining = rottingTeleport+1
		
		if rottingTeleport > 0:
			rottingTeleport -= 1
			
		elif rottingTeleport <= 0:
			#deletes the pumpkin when rottingTeleport reaches 0
			pumpkinDestroy(true)
			
	return highestPosition


func spawnTracer(oldPosition:Vector2) -> void:
	#apply_impulse(Vector2(0, -60)) # gives a bump of upward velocity on teleport
	
	var rayInst:Node2D = raycast.instantiate()
	
	rayInst.setupRay(self, oldPosition, newPosition)
	
	get_tree().root.add_child(rayInst)
	

func pumpkinDestroy(failure = false):
	GlobalSignalBus.levelFailed.emit()
	self.queue_free()

func save() -> Dictionary:
	var saveDict = {
		"name" : name,
		"posX" : position.x,
		"posY" : position.y,
		"teleports" : rottingTeleport
	}
	return saveDict

func loadJSON(nodeData) -> void:
	rottingTeleport = nodeData["teleports"]

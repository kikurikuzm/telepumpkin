extends RigidBody2D

var poofs:PackedScene = preload("res://Instances/Particles/poofs.tscn")
var teleportNumber:PackedScene = preload("res://Instances/teleportsRemainingNumber.tscn")
var teleportLight:PackedScene = preload("res://Instances/Particles/teleport_light.tscn")
var raycast:PackedScene = preload("res://Instances/Helpers/pumpkinRay.tscn")

@export var rotting:bool = false
@export var rottingTeleport:int = 0

@onready var animationPlayer = $AnimationPlayer
@onready var sprite = $pumpkinSprite

var highlighted:bool = false
var highlightDistortion : float = 0.2

var newPosition

#random size adjustment when pumpkins are spawned
func _init():
	scale.x = randf_range(0.9, 1.05)
	scale.y = scale.x

func _ready():
	if rotting:
		sprite.animation = "rotting"
	#else:
		#animationPlayer.play("normalIdle")

#func _physics_process(delta):
	

func _process(delta):
	if rotting:
		if rottingTeleport > 6:
			sprite.frame = 0
		else:
			match rottingTeleport:
				1:
					sprite.frame = 5
				2:
					sprite.frame = 4
				3:
					sprite.frame = 3
				4:
					sprite.frame = 2
				5:
					sprite.frame = 1
				6:
					sprite.frame = 0
	
	if highlighted:
		highlightDistortion = lerp(highlightDistortion, 0.16, 0.1)
		sprite.material.set_shader_parameter("distortion_strength", highlightDistortion)
		$selectParticles.emitting = true
		
	else:
		highlightDistortion = lerp(highlightDistortion, 0.0, 0.02)
		sprite.material.set_shader_parameter("distortion_strength", highlightDistortion)
		$selectParticles.emitting = false
		
	highlighted = false


func getVelocity():
	return linear_velocity
	
func traverseManhole(exitPos: Vector2, exitVel: Vector2):
	self.position = exitPos
	self.linear_velocity = exitVel

func teleport(hostPos: Transform2D) -> void:
	#called by the player script when the pumpkin is teleported
	newPosition = hostPos.get_origin()
	self.custom_integrator = true
	
	if rotting:
		var numberInstance = teleportNumber.instantiate()
		get_parent().add_child(numberInstance)
		numberInstance.global_position = global_position
		numberInstance.teleportsRemaining = rottingTeleport
		
		if rottingTeleport > 0:
			rottingTeleport -= 1
			animationPlayer.play("teleport")
			animationPlayer.queue("idle")
		if rottingTeleport <= 0:
			#deletes the pumpkin when rottingTeleport reaches 0
			pumpkinDestroy(true)
			
	#if !rotting:
		#animationPlayer.play("normalTeleport")
		#animationPlayer.queue("normalIdle")

func _integrate_forces(state:PhysicsDirectBodyState2D) -> void:
	if custom_integrator == true:
		linear_velocity.x *= 0.1
		linear_velocity.y *= 0.5
		
		var oldPos:Vector2 = self.global_position + Vector2(0, 20)
		
		state.transform.origin = newPosition
		
		var poofInstance:Node2D = poofs.instantiate()
		poofInstance.hide()
		get_tree().root.add_child(poofInstance)
		poofInstance.global_position = oldPos
		spawnTracer(oldPos)
		poofInstance.show()
		
		await get_tree().physics_frame
		
		self.custom_integrator = false

func spawnTracer(oldPosition:Vector2) -> void:
	apply_impulse(Vector2(0, -60))
	
	var rayInst:Node2D = raycast.instantiate()
	
	rayInst.setupRay(self, oldPosition, newPosition)
	
	get_tree().root.add_child(rayInst)
	

func pumpkinDestroy(failure = false):
	if failure == true:
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

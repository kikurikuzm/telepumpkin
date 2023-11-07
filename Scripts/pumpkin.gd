extends RigidBody2D

#unstable is a basic teleport limit per-pumpkin. work in progress
@export var unstable = false
@export var unstableTeleport : int
var highlighted = false
var maxUnst

@onready var animationPlayer = get_node("pumpkinSprite/abberation/AnimationPlayer")
@onready var animationTree = get_node("pumpkinSprite/abberation/AnimationTree")
@onready var poofs = preload("res://Instances/Particles/poofs.tscn")
@onready var teleportLight = preload("res://Instances/Particles/teleport_light.tscn")
var raycast = load("res://Instances/Helpers/pumpkinRay.tscn")

@onready var sprite = $pumpkinSprite

var highlightDistortion : float = 0.2

var testpos
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var customVelocity = Vector2.ZERO

#random size adjustment when pumpkins are spawned
func _init():
	scale.x = randf_range(0.9, 1.05)
	scale.y = scale.x

func _ready():
	animationPlayer.play("normalIdle")
	if unstable:
		maxUnst = unstableTeleport
		sprite.animation = "rotting"

func _physics_process(delta):
	if unstable:
		sprite.frame = maxUnst/unstableTeleport
	
	var areaArray = $Area2D.get_overlapping_areas()
	for area in areaArray:
		if area.get_parent().is_in_group("manhole"):
			if area.get_parent().enterManhole(linear_velocity) != null:
				var manhole = area.get_parent()
				var exitVariables = manhole.enterManhole(linear_velocity)
				manhole.enterSound(self.linear_velocity.y / 20, randf_range(0.80, 1.0))
				position = exitVariables[0]
				linear_velocity = exitVariables[1]
				area.get_parent().pumpkinAmount -= 1

func getVelocity():
	return linear_velocity
	
func traverseManhole(exitPos: Vector2, exitVel: Vector2):
	position = exitPos
	linear_velocity = exitVel

func _process(delta):
	if highlighted:
		highlightDistortion = lerp(highlightDistortion, 0.16, 0.1)
		sprite.material.set_shader_parameter("distortion_strength", highlightDistortion)
		$selectParticles.emitting = true
		
	else:
		highlightDistortion = lerp(highlightDistortion, 0.0, 0.02)
		sprite.material.set_shader_parameter("distortion_strength", highlightDistortion)
		$selectParticles.emitting = false
		
	highlighted = false
	

func teleport(hostPos: Transform2D) -> void:
	#called by the player script when the pumpkin is teleported
	testpos = hostPos
	custom_integrator = true
	
	if unstable:
		if unstableTeleport > 0:
			unstableTeleport -= 1
			animationPlayer.play("teleport")
			animationPlayer.queue("idle")
		if unstableTeleport <= 0:
			#deletes the pumpkin when unstableTeleport reaches 0
			self.queue_free()
	if !unstable:
		animationPlayer.play("normalTeleport")
		animationPlayer.queue("normalIdle")

func _integrate_forces(state) -> void:
	if custom_integrator == true:
		linear_velocity = Vector2.ZERO
		
		var oldPos = self.global_position + Vector2(0, 20)
		
		state.set_transform(testpos)
		
		var poofInstance = poofs.instantiate()
		get_parent().add_child(poofInstance)
		poofInstance.global_position = oldPos
		spawnTracer(oldPos)
		
		custom_integrator = false

func spawnTracer(oldPosition:Vector2) -> void:
	apply_impulse(Vector2(0, -60))
	
	var rayInst = raycast.instantiate()
	get_parent().add_child(rayInst)
	rayInst.sender = self
	rayInst.global_position = oldPosition
	rayInst.target_position = testpos.get_origin() - rayInst.global_position
	rayInst.get_node("Line2D").add_point(testpos.get_origin() - rayInst.global_position)

func save() -> Dictionary:
	var saveDict = {
		"name" : name,
		"posX" : position.x,
		"posY" : position.y,
		"teleports" : unstableTeleport
	}
	return saveDict

func loadJSON(nodeData) -> void:
	unstableTeleport = nodeData["teleports"]

extends CharacterBody2D

@onready var poofParticles = preload("res://Instances/Particles/poofs.tscn")
@onready var magicBolt = preload("res://Instances/magicBolt.tscn")

const FRICTION = 0.6
var MINRANGE = 0.0
const TELEPORTCOOLDOWN = 240.0
const TELEPORTRANGE = 1.0

var teleportTimer = 1

enum MAGICMODES {
	TELEPORT = 0,
	BOLT = 1
	}

var magicMode = MAGICMODES.TELEPORT

@onready var teleportRange = $teleport
@onready var boltReticle = $boltReticle

func _process(delta):
	velocity *= FRICTION
	velocity = Input.get_vector("left", "right", "moveUp", "down") * 1.7
	
	if Input.is_action_just_pressed("changeMagic"):
		var poofInstance = poofParticles.instantiate()
		get_parent().add_child(poofInstance)
		poofInstance.global_position = position
		
		if magicMode == MAGICMODES.TELEPORT:
			magicMode = MAGICMODES.BOLT
		elif magicMode == MAGICMODES.BOLT:
			magicMode = MAGICMODES.TELEPORT
	
	if Input.is_action_pressed("lookDown") or Input.is_action_pressed("lookUp") or Input.is_action_pressed("lookLeft") or Input.is_action_pressed("lookRight"):
		if Input.is_joy_known(0):
			boltReticle.position.x = lerp(boltReticle.position.x, Input.get_joy_axis(0, JOY_AXIS_RIGHT_X) * 50, 0.4)
			boltReticle.position.y = lerp(boltReticle.position.y, Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y) * 50, 0.4)
		else:
			boltReticle.position = Input.get_vector("lookLeft", "lookRight", "lookUp", "lookDown") * 50
		boltReticle.look_at(global_position)
	
	if magicMode == MAGICMODES.BOLT:
		boltReticle.modulate = lerp(boltReticle.modulate, Color(1, 1, 1, 0.9), 0.3)
	elif magicMode == MAGICMODES.TELEPORT:
		boltReticle.modulate = lerp(boltReticle.modulate, Color(1, 1, 1, 0.0), 0.2)
	
	if Input.is_action_just_pressed("teleport"):
		match magicMode:
			MAGICMODES.TELEPORT:
				if teleportTimer <= 0:
					playerTeleport()
			MAGICMODES.BOLT:
				shootBolt()
	
	move_and_collide(velocity)

func _physics_process(delta):
	if teleportTimer > 0:
		teleportRange.modulate = Color(1, 1, 1, 0.05)
		
		var rangeScale = TELEPORTRANGE / TELEPORTCOOLDOWN
		teleportRange.scale += Vector2(rangeScale, rangeScale)
		teleportTimer -= 1.0
	else:
		teleportRange.modulate = Color(1, 1, 1, 0.8)

func playerTeleport():
	for node in teleportRange.get_overlapping_bodies():
		if node is RGTeleportable:
			node.teleport(self)
			teleportTimer = TELEPORTCOOLDOWN
			teleportRange.scale = Vector2(MINRANGE, MINRANGE)
		else:
			pass

func shootBolt():
	var magicBoltInstance = magicBolt.instantiate()
	get_parent().add_child(magicBoltInstance)
	magicBoltInstance.global_position = position
	magicBoltInstance.rotation_degrees = boltReticle.rotation_degrees - 90

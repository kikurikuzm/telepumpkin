extends PlayerState
class_name playerStretch

@onready var coyoteTimer = $"../../coyoteTimer"
@onready var debugLabel = $"../../debugText"

const MIN_JUMPSTRENGTH = 0
const MAX_JUMPSTRENGTH = 270
var walkspeed = 6.0

var stretchAnimationUpPlayed = false
var stretchAnimationDownPlayed = false

func enter():
	MAXSPEED = 45
	ACCELERATE = 0.012
	animPlayer.play("stretch")

func exit():
	teleportRange.scale = Vector2(1.5, 1.5)
	stretchAnimationDownPlayed = false
	stretchAnimationUpPlayed = false

func update(delta: float):
	pass

func physics_update(delta: float):
	var direction = 0
	debugLabel.text = str(player.jumpstrength)
	if sign(player.velocity.y) == 1:
		coyoteTimer.start(1)
		print("started timer")
	
	if Input.is_action_pressed("left"):
		direction = -1
		playerSprite.rotation_degrees = lerp(playerSprite.rotation_degrees, -3.0, 0.2)
		player.velocity.x = walkspeed * accelerate(direction)
		playerSprite.flip_h = true
	if Input.is_action_pressed("right"):
		direction = 1
		playerSprite.rotation_degrees = lerp(playerSprite.rotation_degrees, 3.0, 0.2)
		player.velocity.x = walkspeed * accelerate(direction)
		playerSprite.flip_h = false
		
	if Input.is_action_just_released("left") or \
	Input.is_action_just_released("right"):
		curveX = 0
	
	if direction == 0:
		player.velocity.x = 0
	
	if Input.is_action_pressed("up"):
		teleportRange.scale.x = lerp(teleportRange.scale.x, 0.9, 0.07)
		teleportRange.scale.y = lerp(teleportRange.scale.y, 3.0, 0.085)
		if player.is_on_floor() or !coyoteTimer.is_stopped():
			player.jumpstrength += 8
			player.jumpstrength = clamp(player.jumpstrength, MIN_JUMPSTRENGTH, MAX_JUMPSTRENGTH)
		#if !stretchAnimationUpPlayed:
			#animPlayer.play("stretchUp")
			#stretchAnimationUpPlayed = true
		
	if Input.is_action_pressed("down"):
		teleportRange.scale.x = lerp(teleportRange.scale.x, 3.0, 0.085)
		teleportRange.scale.y = lerp(teleportRange.scale.y, 0.9, 0.07)
		if !stretchAnimationDownPlayed:
			animPlayer.play("stretchDown")
			stretchAnimationDownPlayed = true
	
	if Input.is_action_just_released("up"):
		animPlayer.play("snapBack")
		if player.is_on_floor() or !coyoteTimer.is_stopped():
			transitioned.emit(self, "playerjump")
		else: transitioned.emit(self, "playerfalling")
		
	if Input.is_action_just_released("down"):
		transitioned.emit(self, "playeridle")
	
	player.velocity.x += friction * sign(player.velocity.x) * -1
	
	player.velocity.x = clampf(player.velocity.x, -MAXSPEED, MAXSPEED)
	player.move_and_slide()

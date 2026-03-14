class_name playerStretch extends PlayerState

@onready var coyoteTimer:Timer = $"../../coyoteTimer"
@onready var debugLabel = $"../../debugText"

var walkspeed = 6.0
var residualSpeed = 0
var jumpStrengthIncrease = JUMPSTRENGTH_INCREASE

var stretchAnimationUpPlayed = false
var stretchAnimationDownPlayed = false

var maxJumpStrengthReached:bool = false
var modulateTween:Tween = null

var hasHadAirTimer = false

const MIN_JUMPSTRENGTH = 0
const MAX_JUMPSTRENGTH = 250
const JUMPSTRENGTH_INCREASE = 2.1

const MAX_STRETCH_WALK_SPEED = 45
const MAX_RESIDUAL_WALK_SPEED = 125

const RESIDUAL_SPEED_DECREASE_STR = 0.1
const WALK_SPEED_DECREASE_STR = 0.1

func enter():
	if player.is_on_floor():
		player.jumpstrength = 165
		jumpStrengthIncrease = JUMPSTRENGTH_INCREASE
	elif !player.is_on_floor():
		player.jumpstrength = 185
		jumpStrengthIncrease = JUMPSTRENGTH_INCREASE + 1
	
	MAXSPEED = 125
	ACCELERATE = 0.012
	residualSpeed = player.velocity.x
	
	teleportRange.scaleOverridden = true
	maxJumpStrengthReached = false
	
	animPlayer.play("jumpSquat")

func exit():
	MAXSPEED = 125
	teleportRange.scaleOverridden = false
	stretchAnimationDownPlayed = false
	stretchAnimationUpPlayed = false
	playerSprite.self_modulate = PLAYER_DEFAULT_COLOUR

func update(delta: float):
	#if !player.is_on_floor() and coyoteTimer.is_stopped() and hasHadAirTimer == true:
		#playerSprite.self_modulate = Color(1.0, 1.0, 1.0)
	pass

func physics_update(delta: float):
	super(delta)
	
	if player.is_on_floor():
		hasHadAirTimer = false
	
	if !player.is_on_floor() and coyoteTimer.is_stopped() and player.jumpsRemaining > 0 and hasHadAirTimer == false:
		coyoteTimer.start(AIRTIME)
		playerSprite.self_modulate = MAGIC_FULL_CHARGED_COLOUR
		hasHadAirTimer = true
	
	var direction: int = 0
	debugLabel.text = str(player.jumpstrength)
	#if sign(player.velocity.y) == 1:
		#coyoteTimer.start(1)
		#print("started timer")
	
	if Input.is_action_pressed("left"):
		direction = -1
		#playerSprite.rotation_degrees = lerp(playerSprite.rotation_degrees, -3.0, 0.2)
		#playerSprite.skew = deg_to_rad(lerp(deg_to_rad(playerSprite.skew), -15.0, 0.001))
		if abs(player.velocity.x) < MAX_STRETCH_WALK_SPEED:
			player.velocity.x += walkspeed * direction
		playerSprite.flip_h = true
	
	if Input.is_action_pressed("right"):
		direction = 1
		#playerSprite.rotation_degrees = lerp(playerSprite.rotation_degrees, 3.0, 0.2)
		#playerSprite.skew = deg_to_rad(lerp(deg_to_rad(playerSprite.skew), 15.0, 0.001))
		if abs(player.velocity.x) < MAX_STRETCH_WALK_SPEED:
			player.velocity.x += walkspeed * direction
		playerSprite.flip_h = false
		
	#if Input.is_action_just_released("left") or \
	#Input.is_action_just_released("right"):
		#curveX = 0
	
	#if direction == 0:
		#player.velocity.x = 0
	
	if Input.is_action_pressed("up"):
		teleportRange.scale.x = lerp(teleportRange.scale.x, 0.9, 0.07)
		teleportRange.scale.y = lerp(teleportRange.scale.y, 3.0, 0.085)
		if player.is_on_floor() or !coyoteTimer.is_stopped():
			player.jumpstrength += jumpStrengthIncrease
			player.jumpstrength = clamp(player.jumpstrength, MIN_JUMPSTRENGTH, MAX_JUMPSTRENGTH)
			
			if maxJumpStrengthReached == false and player.jumpstrength >= MAX_JUMPSTRENGTH:
				if modulateTween: modulateTween.kill()
				modulateTween = self.create_tween()
				
				maxJumpStrengthReached = true
				playerSprite.self_modulate = PLAYER_FLASH_COLOUR
				
				modulateTween.tween_property(playerSprite, "self_modulate", MAGIC_FULL_CHARGED_COLOUR, 0.5).set_trans(Tween.TRANS_CUBIC)
			
		#if !stretchAnimationUpPlayed:
			#animPlayer.play("stretchUp")
			#stretchAnimationUpPlayed = true
		
	if Input.is_action_pressed("down"):
		teleportRange.scale.x = lerp(teleportRange.scale.x, 3.5, 0.085)
		teleportRange.scale.y = lerp(teleportRange.scale.y, 0.9, 0.07)
		if !stretchAnimationDownPlayed:
			#animPlayer.play("stretchDown")
			stretchAnimationDownPlayed = true
	
	if Input.is_action_just_released("up"):
		animPlayer.play("snapBack")
		
		if modulateTween: modulateTween.kill()
		playerSprite.self_modulate = PLAYER_DEFAULT_COLOUR
		
		if player.is_on_floor():
			transitionToState(STATE_JUMPING)
			return
		
		#Check to avoid using up a jump even when the coyote timer is active
		if !coyoteTimer.is_stopped() and player.jumpsRemaining == player.maxJumps: 
			transitionToState(STATE_JUMPING)
			return
		elif coyoteTimer.is_stopped() and player.jumpsRemaining == player.maxJumps:
			player.jumpsRemaining -= 1
		
		#Different visuals for a mid-air jump
		if player.jumpsRemaining != player.maxJumps and player.jumpsRemaining > 0:
			var playerVelocityDirection:Vector2 = player.velocity.normalized()
			transitionToState(STATE_JUMPING)
			
			playerSprite.self_modulate = PLAYER_FLASH_COLOUR
			modulateTween = self.create_tween()
			
			modulateTween.tween_property(playerSprite, "self_modulate", PLAYER_DEFAULT_COLOUR, 0.2)
			
			%doublejumpParticles.process_material.direction = Vector3(-playerVelocityDirection.x, playerVelocityDirection.y, 0)
			var particles: GPUParticles2D = %doublejumpParticles.duplicate()
			get_tree().root.add_child(particles)
			particles.finished.connect(func():
				particles.queue_free()
			)
			
			particles.global_position = player.global_position
			particles.restart()
		else:
			transitioned.emit(self, "playerfalling")
		
	if Input.is_action_just_released("down"):
		transitioned.emit(self, "playeridle")
		
	if Input.is_action_just_pressed("kick"):
		transitioned.emit(self, "playerKick")
	
	
	player.velocity.x = lerp(player.velocity.x, 0.0, WALK_SPEED_DECREASE_STR)
	residualSpeed = lerp(residualSpeed, 0.0, RESIDUAL_SPEED_DECREASE_STR)
	residualSpeed = floorf(residualSpeed)
	
	player.velocity.x = clampf(player.velocity.x, -(MAXSPEED + abs(residualSpeed)), (MAXSPEED + abs(residualSpeed)))
	residualSpeed = clampf(residualSpeed, -MAX_RESIDUAL_WALK_SPEED, MAX_RESIDUAL_WALK_SPEED)

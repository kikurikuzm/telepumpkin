extends PlayerState
class_name playerKick

@onready var kickArea = $"../../kickArea"

var hasImpacted = false
var inKick = false

const DEFAULT_HORIZONTAL_KICK_STRENGTH = 100
const PERFECT_HORIZONTAL_KICK_STRENGTH = 150
const DEFAULT_VERTICAL_KICK_STRENGTH = 50
const PERFECT_VERTICAL_KICK_STRENGTH = 80

var kickStrengthHorizontal = 100
var kickStrengthVertical = 50
var kickDirection = 1
var kickPausetime = 0.04

func enter():
	hasImpacted = false
	playerSprite.rotation_degrees = 0
	animPlayer.play("kick")
	
	friction = 0.01
	
	if Input.is_action_pressed("left"):
		playerSprite.flip_h = true
		kickDirection = -1
	elif Input.is_action_pressed("right"):
		playerSprite.flip_h = false
		kickDirection = 1

func exit():
	pass

func update(delta: float):
	#if Input.is_action_pressed("kick") and animPlayer.current_animation == "kickWindup":
		#pass
	#elif !Input.is_action_pressed("kick") and animPlayer.current_animation == "kickWindup":
		#friction = 0.01
		#animPlayer.play("kick")
		#await animPlayer.animation_finished
		#transitioned.emit(self, "playerIdle")
			
	if !animPlayer.is_playing() and !inKick:
		transitioned.emit(self, "playerStop")

func physics_update(delta: float):
	super(delta)
	
	if playerSprite.animation == "kick" and playerSprite.frame == 3 and !hasImpacted:
		if kickArea.has_overlapping_bodies():
			for i in kickArea.get_overlapping_bodies():
				if i.is_in_group("pumpkin") and is_instance_valid(i) and !hasImpacted:
					inKick = true
					
					kickStrengthHorizontal = DEFAULT_HORIZONTAL_KICK_STRENGTH
					kickStrengthVertical = DEFAULT_VERTICAL_KICK_STRENGTH
					
					
					var playerOldVelocity = player.velocity
					
					kickPausetime = abs(playerOldVelocity.x / 2000) + 0.01
					
					if kickPausetime > 0.06:
						kickStrengthHorizontal = PERFECT_HORIZONTAL_KICK_STRENGTH
						kickStrengthVertical = PERFECT_VERTICAL_KICK_STRENGTH
						
						var hitTimer = Timer.new()
						self.add_child(hitTimer)
						print(kickPausetime)
						
						playerSprite.self_modulate = Color(99.0, 99.0, 99.0)
						hitTimer.start(kickPausetime)
						hasImpacted = true
						animPlayer.pause()
						$"../../kickBlinkSFX".play()
						
						Engine.time_scale = 0.1
						await hitTimer.timeout
						Engine.time_scale = 1.0
						
						#$"../../kickSFX".play()
						animPlayer.play()
						hitTimer.queue_free()
						playerSprite.self_modulate = Color(1.0, 1.0, 1.0)
					
					hasImpacted = true
					i.apply_impulse(Vector2((kickStrengthHorizontal*kickDirection)*(abs(playerOldVelocity.x)/45 + 1), -kickStrengthVertical), Vector2(0,0))
					
					inKick = false
	if hasImpacted:
		friction = 1.0
	
	player.velocity.x = lerp(player.velocity.x, 0.0, friction)
	
	player.move_and_slide()
	

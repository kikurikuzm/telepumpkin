extends PlayerState
class_name playerKick

@onready var kickArea = $"../../kickArea"
@onready var kickStopTimer:Timer = $"../../kickFailTimer"

var hasImpacted:bool = false
var hasProducedEffect:bool = false
var hasPerfectKickFlashed:bool = false
var inKick:bool = false
var alreadyImpulsedTargets:Array[Node2D] = []

var kickStrengthHorizontal = 100
var kickStrengthVertical = 50
var kickDirection = 1
var kickPausetime = 0.04

const DEFAULT_HORIZONTAL_KICK_STRENGTH = 60
const PERFECT_HORIZONTAL_KICK_STRENGTH = 120
const DEFAULT_VERTICAL_KICK_STRENGTH = 35
const PERFECT_VERTICAL_KICK_STRENGTH = 50

const MAX_VERTICAL_KICK_STRENGTH := 10
const MAX_HORIZONTAL_KICK_STRENGTH := 300

const MAX_KICK_WAIT_TIME := 0.5
const MIN_REQUIRED_MOVEMENT_VELOCITY := 60.0

const PERFECT_KICK_PAUSE_THRESHOLD := 0.46

const KICK_AREA_HORIZONTAL_OFFSET := 8

func enter():
	print_debug("Initiated a kick")
	hasImpacted = false
	alreadyImpulsedTargets.clear()
	playerSprite.rotation_degrees = 0
	animPlayer.play("kickWindup")
	
	friction = 0.01
	
	if playerSprite.flip_h == true:
		kickDirection = -1
	elif playerSprite.flip_h == false:
		kickDirection = 1
	
	if Input.is_action_pressed("left"):
		playerSprite.flip_h = true
		kickArea.position.x = -KICK_AREA_HORIZONTAL_OFFSET
		kickDirection = -1
	elif Input.is_action_pressed("right"):
		playerSprite.flip_h = false
		kickArea.position.x = KICK_AREA_HORIZONTAL_OFFSET
		kickDirection = 1
	
	kickStopTimer.start(MAX_KICK_WAIT_TIME)
	hasPerfectKickFlashed = false


func exit():
	playerSprite.self_modulate = Color(1.0, 1.0, 1.0)
	playerSprite.scale = Vector2(1.0, 1.0)

func update(delta: float):
	if Input.is_action_pressed("kick") and animPlayer.current_animation == "kickWindup":
		print(player.velocity)
		if abs(player.velocity.x) < MIN_REQUIRED_MOVEMENT_VELOCITY and kickStopTimer.is_stopped():
			print_debug("kick did not succeed, changing to playerstop")
			transitioned.emit(self, "playerStop")
	elif !Input.is_action_pressed("kick") and animPlayer.current_animation == "kickWindup":
		friction = 0.01
		animPlayer.play("kick")
		#await animPlayer.animation_finished
		#transitioned.emit(self, "playerIdle")
			
	if !animPlayer.is_playing() and !inKick and Engine.time_scale == 1.0:
		print_debug("Finished kick, changing to playerstop")
		transitioned.emit(self, "playerStop")

func physics_update(delta: float):
	super(delta)
	
	if playerSprite.animation == "kick" and playerSprite.frame == 3:
		if hasPerfectKickFlashed == false: 
			playerSprite.self_modulate = Color(2.5, 1.5, 1.0)
			hasPerfectKickFlashed = true
		
		if kickArea.has_overlapping_bodies():
			for i in kickArea.get_overlapping_bodies():
				if alreadyImpulsedTargets.has(i): continue
				
				if i != null and i is TeleportableObject:
					inKick = true
					hasProducedEffect = false
					
					kickStrengthHorizontal = DEFAULT_HORIZONTAL_KICK_STRENGTH
					kickStrengthVertical = DEFAULT_VERTICAL_KICK_STRENGTH
					
					var playerOldVelocity = player.velocity
					
					kickPausetime = abs(playerOldVelocity.x / 200) + 0.01
					
					#region Perfect Kick Code
					if kickPausetime > PERFECT_KICK_PAUSE_THRESHOLD:
						kickStrengthHorizontal = PERFECT_HORIZONTAL_KICK_STRENGTH
						kickStrengthVertical = PERFECT_VERTICAL_KICK_STRENGTH
						
						CameraManager.setZoom(CameraManager.getPlayerZoom() + 0.5)
						CameraManager.focusPlayer()
						
						playerSprite.self_modulate = Color(99.0, 99.0, 99.0)
						playerSprite.scale.y += 0.4
						playerSprite.scale.x -= 0.2
						
						var hitTimer = get_tree().create_timer(kickPausetime, true, false, true)
						animPlayer.pause()
						kickStopTimer.paused = true
						
						if !hasProducedEffect:
							$"../../kickBlinkSFX".play()
							hasProducedEffect = true
						
						Engine.time_scale = 0.0
						finishPerfectKick(hitTimer)
					#endregion
					
					if !alreadyImpulsedTargets.has(i) and i != null:
						if i is not TeleportableObject: return
						
						kickStrengthHorizontal = (kickStrengthHorizontal * kickDirection) * (abs(playerOldVelocity.x)/45 + 1)
						kickStrengthVertical = (abs(kickStrengthVertical)*(abs(playerOldVelocity.y)/60 + 1)) * -1
						
						if Input.is_action_pressed("up"):
							var swappedStrength:float = kickStrengthVertical
							kickStrengthVertical = (abs(kickStrengthHorizontal) * 0.8) * -1
							kickStrengthHorizontal = abs(swappedStrength * 0.25) * kickDirection
						else:
							#if kickStrengthVertical > kickStrengthHorizontal:
								#var swappedStrength:float = kickStrengthHorizontal
								#kickStrengthHorizontal = kickStrengthVertical
								#kickStrengthVertical = swappedStrength
								
							kickStrengthVertical = clampf(kickStrengthVertical, -MAX_VERTICAL_KICK_STRENGTH, MAX_VERTICAL_KICK_STRENGTH)
						
						print_debug("Kick strength vector : %s, player velocity : %s" % [str(Vector2(kickStrengthHorizontal, kickStrengthVertical)), str(playerOldVelocity)])
						
						i.setVelocity(Vector2(kickStrengthHorizontal, kickStrengthVertical))
						alreadyImpulsedTargets.append(i)
						hasImpacted = true
					
					inKick = false
	
	elif playerSprite.animation == "kick" and playerSprite.frame == 4:
		var colourTween:Tween = get_tree().create_tween()
		colourTween.tween_property(playerSprite, "self_modulate", Color(1.0,1.0,1.0), 0.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	if hasImpacted:
		friction = 1.0
	
	player.velocity.x = lerp(player.velocity.x, 0.0, friction)
	

func finishPerfectKick(hitTimer:SceneTreeTimer) -> void:
	print_debug("Started hittimer await")
	await hitTimer.timeout
	animPlayer.play()
	playerSprite.self_modulate = Color(1.0, 1.0, 1.0)
	playerSprite.scale.y -= 0.4
	playerSprite.scale.x += 0.2
	
	CameraManager.removeFocus(player)
	Engine.time_scale = 1.0
	return

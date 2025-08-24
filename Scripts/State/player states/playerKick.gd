extends PlayerState
class_name playerKick

@onready var kickArea = $"../../kickArea"

var hasImpacted:bool = false
var hasProducedEffect:bool = false
var inKick:bool = false
var kickStopTimer:Timer
var alreadyImpulsedTargets:Array[Node2D]

var kickStrengthHorizontal = 100
var kickStrengthVertical = 50
var kickDirection = 1
var kickPausetime = 0.04

const DEFAULT_HORIZONTAL_KICK_STRENGTH = 100
const PERFECT_HORIZONTAL_KICK_STRENGTH = 150
const DEFAULT_VERTICAL_KICK_STRENGTH = 50
const PERFECT_VERTICAL_KICK_STRENGTH = 80
const MAX_KICK_WAIT_TIME := 1.25

func enter():
	hasImpacted = false
	alreadyImpulsedTargets.clear()
	playerSprite.rotation_degrees = 0
	animPlayer.play("kickWindup")
	
	friction = 0.01
	
	if Input.is_action_pressed("left"):
		playerSprite.flip_h = true
		kickDirection = -1
	elif Input.is_action_pressed("right"):
		playerSprite.flip_h = false
		kickDirection = 1
	
	if !kickStopTimer:
		kickStopTimer = Timer.new()
		kickStopTimer.one_shot = true
		self.add_child(kickStopTimer)
	
	kickStopTimer.start(MAX_KICK_WAIT_TIME)


func exit():
	pass

func update(delta: float):
	if Input.is_action_pressed("kick") and animPlayer.current_animation == "kickWindup":
		if abs(player.velocity.x) < 60.0 and kickStopTimer.is_stopped():
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
		if kickArea.has_overlapping_bodies():
			for i in kickArea.get_overlapping_bodies():
				if alreadyImpulsedTargets.has(i): continue
				
				if i != null and i.is_in_group("pumpkin"):
					inKick = true
					hasProducedEffect = false
					
					kickStrengthHorizontal = DEFAULT_HORIZONTAL_KICK_STRENGTH
					kickStrengthVertical = DEFAULT_VERTICAL_KICK_STRENGTH
					
					
					var playerOldVelocity = player.velocity
					
					kickPausetime = abs(playerOldVelocity.x / 200) + 0.01
					if kickPausetime > 0.46:
						kickStrengthHorizontal = PERFECT_HORIZONTAL_KICK_STRENGTH
						kickStrengthVertical = PERFECT_VERTICAL_KICK_STRENGTH
						
						
						playerSprite.self_modulate = Color(99.0, 99.0, 99.0)
						var hitTimer = get_tree().create_timer(kickPausetime, true, true, true)
						animPlayer.pause()
						kickStopTimer.paused = true
						
						if !hasProducedEffect:
							$"../../kickBlinkSFX".play()
							hasProducedEffect = true
						
						Engine.time_scale = 0.0
						finishPerfectKick(hitTimer)
						
					
					if !alreadyImpulsedTargets.has(i) and i != null:
						if Input.is_action_pressed("up"):
							kickStrengthVertical *= 2.5
							kickStrengthHorizontal *= 0.75
						i.apply_impulse(Vector2((kickStrengthHorizontal*kickDirection)*(abs(playerOldVelocity.x)/45 + 1), -kickStrengthVertical), Vector2(0,0))
						alreadyImpulsedTargets.append(i)
						hasImpacted = true
					
					inKick = false
	if hasImpacted:
		friction = 1.0
	
	player.velocity.x = lerp(player.velocity.x, 0.0, friction)
	

func finishPerfectKick(hitTimer:SceneTreeTimer) -> void:
	print_debug("Started hittimer await")
	await hitTimer.timeout
	animPlayer.play()
	playerSprite.self_modulate = Color(1.0, 1.0, 1.0)
	Engine.time_scale = 1.0
	return

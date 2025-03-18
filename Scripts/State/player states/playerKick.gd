extends PlayerState
class_name playerKick

@onready var kickArea = $"../../kickArea"

var hasImpacted = false
var kickStrengthHorizontal = 100
var kickStrengthVertical = 50
var kickDirection = 1

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
			
	if !animPlayer.is_playing():
		transitioned.emit(self, "playerIdle")

func physics_update(delta: float):
	super(delta)
	
	if playerSprite.animation == "kick" and playerSprite.frame == 3 and !hasImpacted:
		if kickArea.has_overlapping_bodies():
			for i in kickArea.get_overlapping_bodies():
				if i.is_in_group("pumpkin"):
					i.apply_impulse(Vector2((kickStrengthHorizontal*kickDirection)*(abs(player.velocity.x)/45 + 1), -kickStrengthVertical), Vector2(0,0))
					hasImpacted = true
	
	player.velocity.x = lerp(player.velocity.x, 0.0, friction)
	
	player.move_and_slide()

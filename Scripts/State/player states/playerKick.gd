extends PlayerState
class_name playerKick

@onready var kickArea = $"../../kickArea"

var hasImpacted = false
var kickStrengthHorizontal = 1500
var kickStrengthVertical = 1500
var kickDirection = 1

func enter():
	hasImpacted = false
	playerSprite.rotation_degrees = 0
	animPlayer.play("kick")
	
	if Input.is_action_pressed("left"):
		playerSprite.flip_h = true
		kickDirection = -1
	elif Input.is_action_pressed("right"):
		playerSprite.flip_h = false
		kickDirection = 1

func exit():
	pass

func update(delta: float):
	if !animPlayer.is_playing():
		transitioned.emit(self, "playerIdle")

func physics_update(delta: float):
	super(delta)
	
	if playerSprite.animation == "kick" and playerSprite.frame == 3 and !hasImpacted:
		if kickArea.has_overlapping_bodies():
			for i in kickArea.get_overlapping_bodies():
				if i.is_in_group("pumpkin"):
					print(player.velocity.x)
					i.apply_impulse(Vector2((kickStrengthHorizontal*kickDirection)*(abs(player.velocity.x)/45 + 1), -kickStrengthVertical), Vector2(0,0))
					print("BANG")
					hasImpacted = true
	
	player.velocity.x = lerp(player.velocity.x, 0.0, 0.01)
	
	player.move_and_slide()

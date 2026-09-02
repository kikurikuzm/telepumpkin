extends PlayerState
class_name playerJump

@onready var coyoteTimer = $"../../coyoteTimer"
@onready var audio = $"../../fallThump"

@onready var jumpAudio = preload("res://Audio/sfx/jumpNoise.ogg")

@export var hoistContainer: HoistContainer = null

const DEFAULT_HORIZONTAL_BOOST := 40
const DEFAULT_AIR_CONTROL := 2.0
var horizontalBoost := DEFAULT_HORIZONTAL_BOOST

func enter(args := []):
	player.jumpsRemaining -= 1
	
	if is_instance_valid(hoistContainer):
		if !hoistContainer.current_objects.is_empty():
			player.jumpsRemaining = 0
	
	
	coyoteTimer.stop()
	animPlayer.play("jump")
	player.velocity.y = player.jumpstrength * -1
	player.gravity = gvars.playerGravity / 1.2
	
	if args.size() > 0: 
		player.velocity.x = args[0]
	else:
		player.velocity.x += horizontalBoost * Input.get_axis("left", "right")

func exit():
	player.jumpstrength = 0
	player.airControl = DEFAULT_AIR_CONTROL
	horizontalBoost = DEFAULT_HORIZONTAL_BOOST

func update(delta: float):
	if Input.is_action_just_pressed("object_hoist"):
		if hoistContainer.canHoist():
			for node in interactionArea.get_overlapping_bodies() + interactionArea.get_overlapping_areas():
				var children: Array[Node] = node.get_parent().get_children() if node is Area2D else node.get_children()
				var parent: Node = node if node is not Area2D else node.get_parent()
				for child in children:
					if child is HoistAttributes:
						transitionToState("playerhoisting", parent)
						return
	
	if Input.is_action_just_pressed("kick"):
		transitionToState(STATE_KICKING)
		return

func physics_update(delta: float):
	super(delta)
	
	player.velocity.x += Input.get_axis("left", "right") * player.airControl
	
	if player.velocity.y >= 0:
		transitionToState(STATE_FALLING)
	#elif player.is_on_floor():
		#transitioned.emit(self, "playerstop")
	#player.move_and_slide()

extends Camera3D

@onready var player = get_parent().get_parent().get_node("player")
@onready var cameraFollowing = player.get_node("Marker3D")

func _process(delta):
	global_position = lerp(global_position, cameraFollowing.global_position, 0.2)
	global_rotation = cameraFollowing.global_rotation
	
	#global_rotation = lerp(global_rotation, cameraFollowing.global_rotation, 0.15)

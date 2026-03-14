extends CharacterBody2D
class_name RGTeleportable

func teleport(host):
	self.global_position = host.global_position

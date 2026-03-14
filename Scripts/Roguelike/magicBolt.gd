extends CharacterBody2D

func _process(delta):
	velocity += Vector2(0, -0.08).rotated(rotation)
	move_and_collide(velocity)

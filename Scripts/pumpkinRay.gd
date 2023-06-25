extends RayCast2D

var sender
var opacity = 1.0

func _process(delta):
	opacity -= 0.01
	$Line2D.modulate = Color(1.0,1.0,1.0,opacity)
	if is_colliding():
		var peater = get_collider().get_parent()
		if sender != null:
			peater.eat()
			sender.queue_free()
			sender = null
	if opacity <= 0:
		self.queue_free()
		

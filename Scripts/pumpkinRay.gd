extends RayCast2D

var sender:Node2D #The node that spawned this ray

var originPoint:Vector2 = Vector2.ZERO
var targetPoint:Vector2 = Vector2.ZERO

var opacity:float = 1.0

func _ready() -> void:
	self.global_position = originPoint
	self.target_position = targetPoint - originPoint
	
	self.get_node("Line2D").add_point(targetPoint - originPoint)
	
	await get_tree().process_frame
	
	self.show()

func _process(_delta):
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

func setupRay(sender:Node2D, originPoint:Vector2, targetPoint:Vector2) -> void:
	self.originPoint = originPoint
	self.targetPoint = targetPoint
	self.sender = sender

class_name HoistContainer extends Node2D

@export var parent: Node2D
@export var dropping_space_check: RayCast2D
@export var max_objects: int = 2
var current_objects: Array[Node2D] = []

func _process(delta: float) -> void:
	pass


func hoistObject(object: Node2D) -> void:
	if current_objects.size() < max_objects:
		object.reparent(self, false)
		if object.has_method("onHoist"):
			object.call("onHoist")
		elif object.has_method("on_hoist"):
			object.call("on_hoist")
			
		if !current_objects.back():
			object.global_position = self.global_position
		else:
			var top_object: Node2D = current_objects.back()
			object.global_position == top_object.global_position
			for child in top_object.get_children():
				if child is CollisionShape2D:
					object.global_position.y -= child.shape.get_rect().size.y * current_objects.size()
					break
		object.reset_physics_interpolation()
		#self.add_child(object)
		current_objects.append(object)

func dropHoistedObject() -> void:
	if current_objects.size() <= 0: return
	
	var dropping_object = current_objects.pop_back()
	dropping_object.reparent(parent.get_parent(), false)
	dropping_object.global_position = parent.global_position
	dropping_object.reset_physics_interpolation()
	for child in dropping_object.get_children():
		if child is CollisionShape2D:
			parent.global_position.y -= child.shape.get_rect().size.y * 4
			break
	
	if dropping_object.has_method("onUnhoist"):
		dropping_object.call("onUnhoist")
	elif dropping_object.has_method("on_unhoist"):
		dropping_object.call("on_unhoist")
			


func canHoist() -> bool:
	return current_objects.size() < max_objects


func canDrop() -> bool:
	if is_instance_valid(dropping_space_check):
		if dropping_space_check.is_colliding(): return false
	return current_objects.size() > 0

class_name HoistContainer extends Node2D

class HoistedObject:
	var object: Node2D
	var original_parent: Node
	
	func _init(object: Node2D, original_parent: Node) -> void:
		self.object = object
		self.original_parent = original_parent

@export var parent: Node2D
@export var dropping_space_check: RayCast2D
@export var max_objects: int = 2

var current_objects: Array[HoistedObject] = []
var top_offset: float = 0.0

func _process(delta: float) -> void:
	pass


func hoistObject(object: Node2D, originalParent: Node) -> void:
	if current_objects.size() < max_objects:
		object.reparent(self, false)
		if object.has_method("onHoist"):
			object.call("onHoist")
		elif object.has_method("on_hoist"):
			object.call("on_hoist")
			
		if !current_objects.back():
			object.global_position = self.global_position
		else:
			var top_object: Node2D = current_objects.back().object
			object.global_position = top_object.global_position
			for child in top_object.get_children():
				if child is CollisionShape2D:
					object.global_position.y -= (child.shape.get_rect().size.y) - randf_range(2.0, 4.0)
					break
		
		top_offset = object.global_position.y - self.global_position.y
		object.reset_physics_interpolation()
		#self.add_child(object)
		var newEntry: HoistedObject = HoistedObject.new(object, originalParent)
		current_objects.append(newEntry)

func dropHoistedObject() -> void:
	if current_objects.size() <= 0: return
	
	var dropping_object_data: HoistedObject = current_objects.pop_back()
	var dropping_object: Node2D = dropping_object_data.object
	
	if is_instance_valid(dropping_object_data.original_parent):
		dropping_object.reparent(dropping_object_data.original_parent, false)
	else:
		dropping_object.reparent(get_tree().get_first_node_in_group(LevelLoader.ACTIVE_LEVEL_GROUP), false)
	
	var object_future_position: Vector2 = parent.global_position
	
	dropping_object.reset_physics_interpolation()
	for child in dropping_object.get_children():
		if child is CollisionShape2D:
			parent.global_position.y -= child.shape.get_rect().size.y
			break
	
	dropping_object.global_position = object_future_position
	dropping_object.reset_physics_interpolation()
	
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

@tool
extends EditorElement
class_name cameraZone

@export var collisionShapeTransform = Vector4.ZERO ##X position, Y position, X scale, Y scale

@onready var area2D = $Area2D
@onready var collisionShape2D = $Area2D/CollisionShape2D

@onready var mainCamera = get_parent().get_parent().mainCamera

func _process(delta):
	if !collisionShapeTransform == Vector4.ZERO:
		collisionShape2D.position.x = collisionShapeTransform.x
		collisionShape2D.position.y = collisionShapeTransform.y
		collisionShape2D.scale.x = collisionShapeTransform.z
		collisionShape2D.scale.y = collisionShapeTransform.w
		

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		mainCamera.changeParent(self)

func _on_area_2d_body_exited(body):
	mainCamera.returnToParent()

func _on_check_if_empty_timeout():
	if !area2D.has_overlapping_bodies():
		mainCamera.returnToParent()

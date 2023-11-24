extends EditorElement
class_name cameraZone

@onready var area2D = $Area2D
@onready var collisionShape2D = $Area2D/CollisionShape2D

@onready var mainCamera = get_parent().get_parent().mainCamera

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		mainCamera.changeParent(self)

func _on_area_2d_body_exited(body):
	mainCamera.returnToParent()

func _on_check_if_empty_timeout():
	if !area2D.has_overlapping_bodies():
		mainCamera.returnToParent()

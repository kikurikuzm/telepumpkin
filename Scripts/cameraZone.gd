@tool
extends EditorElement
class_name CameraZone

@export var collisionShapeTransform = Rect2(0, 0, 1.0, 1.0) ##X position, Y position, X scale, Y scale
@export var cameraZoom : float = 3.0

@onready var area2D = $Area2D
@onready var collisionShape2D = $Area2D/CollisionShape2D
@onready var exampleCamera = $exampleBounds

func _ready() -> void:
	collisionShape2D.position.x = collisionShapeTransform.position.x
	collisionShape2D.position.y = collisionShapeTransform.position.y
	collisionShape2D.scale.x = collisionShapeTransform.size.x
	collisionShape2D.scale.y = collisionShapeTransform.size.y

func _process(delta):
	if Engine.is_editor_hint():
		collisionShape2D.position.y = collisionShapeTransform.position.y
		collisionShape2D.position.x = collisionShapeTransform.position.x
		collisionShape2D.scale.x = collisionShapeTransform.size.x
		collisionShape2D.scale.y = collisionShapeTransform.size.y
	
	if is_instance_valid(exampleCamera):
		exampleCamera.zoom = Vector2(cameraZoom, cameraZoom)

#func _physics_process(delta):
	#for i in area2D.get_overlapping_bodies():
		#if i.is_in_group("player"):
			#cameraZoneGetCamera()

func _on_area_2d_body_entered(body):
	if body.is_in_group("entity_player_body"):
		cameraZoneGetCamera()

func _on_area_2d_body_exited(body):
	if body.is_in_group("entity_player_body"):
		cameraZoneReturnCamera()

#func _on_check_if_empty_timeout():
	#if !area2D.has_overlapping_bodies():
		#cameraZoneReturnCamera()

func cameraZoneGetCamera():
	CameraManager.setZoom(cameraZoom)
	CameraManager.setCurrentFocus(self)

func cameraZoneReturnCamera():
	CameraManager.removeFocus(self)

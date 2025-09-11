@tool
class_name CameraZone extends EditorElement

@export var collisionShapeTransform : Rect2 = Rect2(0, 0, 1.0, 1.0) ## The dimensions and position of the area which will cause the zone to activate.
@export_range(1.0, 10.0, 0.1) var cameraZoom : float = 3.0
@export_range(0.0, 1.0, 0.01) var cameraSmoothing : float = 0.15 ## How fast the camera's movement and zooming should interpolate to the next position.

@onready var area2D:Area2D = $Area2D
@onready var collisionShape2D:CollisionShape2D = $Area2D/CollisionShape2D
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
	CameraManager.setupNewFocus(self, cameraZoom, cameraSmoothing)

func cameraZoneReturnCamera():
	CameraManager.removeFocus(self)

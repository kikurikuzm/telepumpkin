@tool
extends EditorElement
class_name cameraZone

@export var collisionShapeTransform = Vector4.ZERO ##X position, Y position, X scale, Y scale
@export var usesCustomTransform = false
@export var overrideCameraZoom = false
@export var cameraZoom : float = 3.0

@onready var area2D = $Area2D
@onready var collisionShape2D = $Area2D/CollisionShape2D
@onready var exampleCamera = $exampleBounds

func _process(delta):
	if usesCustomTransform:
		collisionShape2D.position.x = collisionShapeTransform.x
		collisionShape2D.position.y = collisionShapeTransform.y
		collisionShape2D.scale.x = collisionShapeTransform.z
		collisionShape2D.scale.y = collisionShapeTransform.w
	elif !usesCustomTransform:
		collisionShape2D.position = Vector2.ZERO
		collisionShape2D.scale = Vector2(1, 1)
	
	if is_instance_valid(exampleCamera):
		exampleCamera.visible = overrideCameraZoom
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
	GlobalSignalBus.requestCameraFocus.emit(self)
	if overrideCameraZoom:
		GlobalSignalBus.requestCameraZoomChange.emit(cameraZoom)
		return

func cameraZoneReturnCamera():
	GlobalSignalBus.returnCameraFocus.emit()

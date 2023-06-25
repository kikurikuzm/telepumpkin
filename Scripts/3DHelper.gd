extends Node2D

@export var camPath : String

@onready var sceneCam3d
@onready var currentCam2d

func _ready():
	assert(get_parent().get_node(camPath), "Path is incorrect")
	sceneCam3d = get_parent().get_node(camPath)

func _process(delta):
	currentCam2d = get_parent().get_viewport().get_camera_2d()
	print(sceneCam3d.position)
	sceneCam3d.position.x = currentCam2d.global_position.x / 100
	#sceneCam3d.position.y = currentCam2d.global_position.y / 500

extends Node2D

@onready var tilemap = get_parent()

@onready var mainCast = get_node("rayHolder")

@onready var upCast = get_node("rayHolder/up").is_colliding()
@onready var downCast = get_node("rayHolder/down").is_colliding()
@onready var leftCast = get_node("rayHolder/left").is_colliding()
@onready var rightCast = get_node("rayHolder/right").is_colliding()


var used_cells

func _ready():
	used_cells = tilemap.get_used_cells(0)

func _process(delta):
	for cell in used_cells:
		get_node("rayHolder/right").force_raycast_update()
		get_node("rayHolder/left").force_raycast_update()
		get_node("rayHolder/up").force_raycast_update()
		get_node("rayHolder/down").force_raycast_update()
		mainCast.position = cell
		match upCast and downCast and leftCast and rightCast:
			true and true and true and true:
				tilemap.set_cell(0, cell, 0)
			true and true and true and false:
				tilemap.set_cell(0, cell, 1, Vector2i(0,0), 4)
				print("right facing side block")
			true and true and false and false:
				print("up facing pillar block")
			true and false and false and false:
				tilemap.set_cell(0, cell, 1)
				print("up facing side block")
			false and false and false and false:
				print("single block")
			false and false and false and true:
				tilemap.set_cell(0, cell, 4, Vector2i(4, 0), 1)
				print("left facing stick block")
			false and false and true and true:
				print("right facing pillar block")
			false and true and true and true:
				tilemap.set_cell(0, cell, 4, Vector2i(4, 0), 2)
				print("down facing stick block")
			false and false and true and false:
				tilemap.set_cell(0, cell, 1, Vector2i(0,0), 3)
				print("left facing side block")
			
			

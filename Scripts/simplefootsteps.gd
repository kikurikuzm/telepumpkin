extends RayCast2D

@export var grass1 = AudioStream
@export var grass2 = AudioStream
@export var grass3 = AudioStream
@export var metal1 = AudioStream
@export var metal2 = AudioStream
@export var metal3 = AudioStream
@export var wood1 = AudioStream
@export var wood2 = AudioStream
@export var wood3 = AudioStream

@export var farmlandTiles : TileSet
@export var cityTiles : TileSet
@export var woodTiles : TileSet

@onready var gStream = [grass1, grass2, grass3]
@onready var mStream = [metal1, metal2, metal3]
@onready var wStream = [wood1, wood2, wood3]

@export var footStream : AudioStreamPlayer2D


func _on_animation_player_animation_started(anim_name):
	var currentTileMap
	
	if get_collider() is TileMap: 
		currentTileMap = get_collider()
	
	if is_instance_valid(currentTileMap):
		if currentTileMap.tile_set == farmlandTiles:
			gStream.shuffle()
			footStream.stream = gStream[0]
			print("goop")
		if currentTileMap.tile_set == cityTiles:
			mStream.shuffle()
			footStream.stream = mStream[0]
		if currentTileMap.tile_set == woodTiles:
			wStream.shuffle()
			footStream.stream = wStream[0]

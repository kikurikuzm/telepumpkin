extends Node2D

@onready var raycast = get_node("RayCast2D")
@onready var audioPlayer = get_node("AudioStreamPlayer2D")
@onready var timer = get_node("Timer")

@export var fxSpeed = 0.0

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

var mainStreams = [gStream, mStream, wStream]

var currentTileMap
var currentTile

func _process(delta):
	if raycast.get_collider() is TileMap: 
		currentTileMap = raycast.get_collider()

func mainStep():
	if is_instance_valid(currentTileMap):
		if timer.is_stopped():
			if currentTileMap.tile_set == farmlandTiles:
				gStream.shuffle()
				audioPlayer.stream = gStream[0]
			if currentTileMap.tile_set == cityTiles:
				mStream.shuffle()
				audioPlayer.stream = mStream[0]
			if currentTileMap.tile_set == woodTiles:
				wStream.shuffle()
				audioPlayer.stream = wStream[0]
			
			audioPlayer.pitch_scale = randf_range(0.9, 1.15)
			if !audioPlayer.playing:
				audioPlayer.play()
			timer.start(fxSpeed)

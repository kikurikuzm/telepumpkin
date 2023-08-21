extends RayCast2D

@onready var animatedSprite = $"../AnimatedSprite2D"

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
@export var sewerTiles : TileSet
@export var woodTiles : TileSet

@onready var gStream = [grass1, grass2, grass3]
@onready var mStream = [metal1, metal2, metal3]
@onready var wStream = [wood1, wood2, wood3]

var hasPlayed = false

@onready var footstepInstance = preload("res://Instances/Helpers/footstep_audio.tscn")

func _process(delta):
	if animatedSprite.animation == "Walk" and animatedSprite.frame == 1:
		if !hasPlayed:
			spawnFootstep()
			return

func spawnFootstep():
	var currentTileMap
	
	if get_collider() is TileMap: 
		currentTileMap = get_collider()
	
	if is_instance_valid(currentTileMap):
		var footStream = footstepInstance.instantiate()
		add_child(footStream)
		
		if currentTileMap.tile_set == farmlandTiles:
			gStream.shuffle()
			footStream.stream = gStream[0]
		if currentTileMap.tile_set == cityTiles or currentTileMap.tile_set == sewerTiles:
			mStream.shuffle()
			footStream.stream = mStream[0]
		if currentTileMap.tile_set == woodTiles:
			wStream.shuffle()
			footStream.stream = wStream[0]
		
		footStream.play()
		hasPlayed = true

func _on_animated_sprite_2d_frame_changed():
	hasPlayed = false

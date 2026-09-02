class_name PipeSystem extends EditorElement

@export var pipes : Array[Pipe]
@onready var entranceCooldown = $Timer

var mainTilemap: TileMapLayer = null

var pipelinePath: Path2D
var pipeline: Curve2D
var currentTile: Vector2i
var entr_closestPos: Vector2
var dest_closestPos: Vector2
var entr_closestTilePos: Vector2i
var dest_closestTilePos: Vector2i
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var lastDirection: TileSet.CellNeighbor = -1

var weightList: Array[Dictionary] = []

var moveCount: int = 1
var lastSuccessfulMove: int = 1
var failedAttempts: int = 0
var isCreatingPipeline: bool = false

var debug_pipe_success: bool = false

const VALID_DIRECTIONS := [TileSet.CELL_NEIGHBOR_BOTTOM_SIDE, TileSet.CELL_NEIGHBOR_LEFT_SIDE, TileSet.CELL_NEIGHBOR_RIGHT_SIDE, TileSet.CELL_NEIGHBOR_TOP_SIDE]
const LOOKAHEAD_MAX := 8
const DEFAULT_ITERATION_DEPTH := 1

signal requestPlayerPositionChange(newPosition:Vector2, newVelocity:Vector2)

signal _finished_iterating

func _ready() -> void:
	#await GlobalSignalBus.restartLevel
	
	for child in get_parent().get_children():
		if child.is_in_group("level_tilemaplayer"):
			mainTilemap = child
			break
	#
	#_constructPipeline(pipes[0], pipes[0].exitPipe)
	#assert(currentTile != Vector2i.ZERO)
	for pipe in pipes:
		pipe.connect("bodyEntered", _pipeEntered)
		if pipe.exitPipe != null:
			_constructPipeline(pipe, pipe.exitPipe)
			_initialize_iteration()
			while (currentTile != dest_closestTilePos):
				_finalize_iteration(_iterate_pipeline())
			#await _finished_iterating

func _constructPipeline(entrance: Pipe, destination: Pipe) -> Path2D:
	if !mainTilemap: return null
	if is_instance_valid(pipelinePath): return null
	
	entr_closestPos = Vector2.INF
	dest_closestPos = Vector2.INF
	entr_closestTilePos = Vector2i.MAX
	dest_closestTilePos = Vector2i.MAX
	var entr_globalPos: Vector2 = entrance.global_position
	var dest_globalPos: Vector2 = destination.global_position
	
	entr_closestTilePos = mainTilemap.local_to_map(mainTilemap.to_local(entr_globalPos))
	dest_closestTilePos = mainTilemap.local_to_map(mainTilemap.to_local(dest_globalPos))
	
	entr_closestPos = entr_globalPos
	dest_closestPos = dest_globalPos
	#for tile in mainTilemap.get_used_cells():
		#var tilePos := mainTilemap.map_to_local(tile)
		#tilePos = mainTilemap.to_global(tilePos)
		#if abs(entr_globalPos - tilePos) < abs(entr_globalPos - entr_closestPos):
			#entr_closestPos = tilePos
			#entr_closestTilePos = tile
		#if abs(dest_globalPos - tilePos) < abs(dest_globalPos - dest_closestPos):
			#dest_closestPos = tilePos
			#dest_closestTilePos = tile
	#
	print_debug(entr_closestTilePos)
	print_debug(dest_closestTilePos)
	
	pipelinePath = Path2D.new()
	pipeline = Curve2D.new()
	self.add_child(pipelinePath)
	pipelinePath.z_index = 999
	pipelinePath.global_position = self.global_position
	pipelinePath.curve = pipeline
	
	isCreatingPipeline = true
	
	_initialize_iteration()
	
	return null


func _get_direction_weight(direction: TileSet.CellNeighbor, current_tile: Vector2i, last_direction: TileSet.CellNeighbor, current_weights: Array, current_pipeline: Curve2D) -> Dictionary:
	#if direction == last_direction: return {}
	var moveChance := 0.0
	var ignoreUpcomingCells: bool = false
	
	var cellPos: Vector2i = mainTilemap.get_neighbor_cell(current_tile, direction)
	var cell: TileData = mainTilemap.get_cell_tile_data(cellPos)
	
	if !cell and cellPos != dest_closestTilePos: # This cell is an empty cell
		moveChance -= 0.5
		#return {}
	elif !cell and cellPos == dest_closestTilePos:
		moveChance += 2
		ignoreUpcomingCells = true
	
	if cell:
		if (cellPos.x >= dest_closestTilePos.x - 1 and cellPos.x <= dest_closestTilePos.x + 1) and \
		(cellPos.y >= dest_closestTilePos.y - 1 and cellPos.y <= dest_closestTilePos.y + 1):
			moveChance += 1
			ignoreUpcomingCells = true
		elif cellPos == dest_closestTilePos:
			moveChance += 2
			#ignoreUpcomingCells = true
	
	var currentGlobal: Vector2 = mainTilemap.to_global(mainTilemap.map_to_local(current_tile))
	var cellGlobal: Vector2 = mainTilemap.to_global(mainTilemap.map_to_local(cellPos))
	
	if last_direction != -1 and last_direction != direction: # Try to discourage turning
		moveChance -= 0.06
	
	for point in current_pipeline.point_count: # Make sure we haven't already done this move before
		if current_pipeline.get_point_position(point) == cellGlobal: 
			moveChance -= 0.8
			#return {}
			break
	
	
	var currentDist: Vector2 = abs(dest_closestPos - currentGlobal)
	var cellDist: Vector2 = abs(dest_closestPos - cellGlobal)
	
	
	
	#if (is_equal_approx(cellDist.x, 0.0) and is_equal_approx(cellDist.y, 0.0)) or cellPos == dest_closestTilePos: # Highly encourage reaching the destination
		#moveChance += 5
	
	#if is_equal_approx(cellDist.x, 0.0):
		#cellDist.x = 0.1
	#if is_equal_approx(cellDist.y, 0.0):
		#cellDist.y = 0.1
	
	var current_total_distance: float = currentDist.x + currentDist.y
	var new_position_total_distance: float = cellDist.x + cellDist.y
	
	if new_position_total_distance < current_total_distance:
		moveChance += (current_total_distance / new_position_total_distance) * 0.04
	elif new_position_total_distance > current_total_distance:
		moveChance -= (current_total_distance / new_position_total_distance) * 0.01
	
	#if currentDist.x > cellDist.x: # If we're moving towards the objective, that's good
		#moveChance += (currentDist.x / cellDist.x) * 0.06
		##moveChance += 0.1
	#elif currentDist.x < cellDist.x: # If we're moving away from the objective, :(
		#moveChance -= (currentDist.x / cellDist.x) * 0.03
	##else: moveChance -= 0.2
	#if currentDist.y > cellDist.y:
		#moveChance += (currentDist.y / cellDist.y) * 0.07
		##moveChance += 0.1
	#elif currentDist.x < cellDist.y: # If we're moving away from the objective, :(
		#moveChance -= (currentDist.y / cellDist.y) * 0.03
	
	
	for tile in mainTilemap.get_surrounding_cells(cellPos): # Checking if this new position will be stuck surrounded by used positions
		for point in current_pipeline.point_count: # Try to discourage the pipes from bunching up
			if current_pipeline.get_point_position(point) == mainTilemap.to_global(mainTilemap.map_to_local(tile)):
				moveChance -= 0.027
		
		if !mainTilemap.get_cell_tile_data(tile): # Try to discourage going near empty tiles
			moveChance -= 0.05
	
	
	var sameDirCount: int = 1
	for i in range(current_weights.size() - 1, -1, -1): # Starting from the current point and increasing chance based off how long the pipe is
		if current_weights[i]["dir"] == direction: sameDirCount += 1
		else: break
		
	
	moveChance += pow(sameDirCount, 1.001) * 0.0001
	
	return {"weight": moveChance, "cell_global_position": cellGlobal, "cell_tile_position": cellPos, "ignore_next": ignoreUpcomingCells}


func _finalize_iteration(moveWeights: Dictionary) -> void:
	var bestDir = TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_SIDE
	var bestResult = {"total_weight": -9999.0}
	if moveWeights.size() <= 0: return
	for direction in moveWeights.keys():
		if moveWeights[direction].is_empty(): continue
		
		if moveWeights[direction]["total_weight"] > bestResult["total_weight"]:
			bestDir = direction
			bestResult = moveWeights[direction]
	
	if bestResult.size() < 2: 
		failedAttempts += 1
		return
	
	lastDirection = bestDir
	currentTile = bestResult["cell_tile_pos"]
	
	pipeline.add_point(bestResult["cell_global_pos"])
	#self.queue_redraw()
	
	weightList.append({"dir": bestDir, "weight": bestResult["total_weight"]})
	lastSuccessfulMove = moveCount
	
	print("Added point " + str(bestResult["cell_global_pos"]))


func _iterate_pipeline(iteration_depth: int = DEFAULT_ITERATION_DEPTH, \
	starting_tile: Vector2i = currentTile, last_direction: TileSet.CellNeighbor = lastDirection, \
	weight_list: Array[Dictionary] = weightList, pipeline_curve: Curve2D = pipeline) -> Dictionary:
	
	var moveWeights: Dictionary = {}
	var directionRouteVariables: Dictionary = {}
	
	for direction in VALID_DIRECTIONS:
		moveWeights.set(direction, {})
		directionRouteVariables.set(direction, { 
			"currentTile": starting_tile, 
			"lastDirection": last_direction, 
			"weightList": weight_list.duplicate(true), 
			"pipeline": pipeline_curve.duplicate(true) 
			})
	
	for direction in VALID_DIRECTIONS:
		var current_direction: TileSet.CellNeighbor = direction
		var current_move_variables: Dictionary = directionRouteVariables[direction]
		var local_first_result: Dictionary = {}
		
		var local_current_tile: Vector2i = current_move_variables["currentTile"]
		var local_last_direction: TileSet.CellNeighbor = current_move_variables["lastDirection"]
		var local_weight_list: Array = current_move_variables["weightList"]
		var local_pipeline: Curve2D = current_move_variables["pipeline"]
		var total_weight: float = 0
	
		for distance in range(LOOKAHEAD_MAX):
			var move_result := _get_direction_weight(current_direction, local_current_tile, local_last_direction, local_weight_list, local_pipeline)
			if move_result.is_empty(): 
				continue
			
			var move_weight: float = move_result["weight"]
			var move_global_pos: Vector2 = move_result["cell_global_position"]
			var move_tile_pos: Vector2i = move_result["cell_tile_position"]
			var move_ignore_upcoming: bool = move_result["ignore_next"]
			
			local_pipeline.add_point(move_global_pos)
			
			if local_first_result.is_empty():
				local_first_result = move_result
			
			local_current_tile = move_tile_pos
			local_weight_list.append({"dir": direction, "weight": move_weight})
			total_weight += move_weight # Diminishing weight based on distance from start
			local_last_direction = current_direction
			
			if iteration_depth > 0:
				var last_point_moves := _iterate_pipeline(iteration_depth - 1, local_current_tile, local_last_direction, local_weight_list, local_pipeline)
				var best_future_move_weight: float = -10.0
				for move in last_point_moves:
					if last_point_moves[move]["total_weight"] > best_future_move_weight:
						best_future_move_weight = last_point_moves[move]["total_weight"]
				
				total_weight += best_future_move_weight * 0.11
				local_weight_list.back()["weight"] += best_future_move_weight
			
			if move_ignore_upcoming: break
			
		
		if local_first_result.is_empty(): continue
		
		moveWeights.set(direction, {
			"total_weight": total_weight, 
			"cell_global_pos": local_first_result["cell_global_position"], 
			"cell_tile_pos": local_first_result["cell_tile_position"],
			"objective_tile_distance": abs(dest_closestTilePos - local_current_tile)
			})
	
	
	return moveWeights


func _initialize_iteration() -> void:
	print(dest_closestTilePos)
	moveCount = 1
	lastSuccessfulMove = 1
	failedAttempts = 0
	currentTile = entr_closestTilePos
	weightList.clear()
	pipeline.clear_points()
	pipeline.add_point(mainTilemap.to_global(mainTilemap.map_to_local(entr_closestTilePos)))


func _pipeEntered(identifier:int, enteringBody:PhysicsBody2D):
	if(entranceCooldown.is_stopped()):
		var emittingInstance : Pipe = instance_from_id(identifier)
		
		var endPosition: Vector2 = Vector2.ZERO
		var pipeTransform: Transform2D
		var leavingVelocity: Vector2 = Vector2.RIGHT
		
		print_debug(emittingInstance)
		
		var pipeIndex = 0
		for pipe in pipes:
			if emittingInstance == pipe:
				if pipeIndex + 1 >= len(pipes):
					pipeTransform = pipes[0].transform
					endPosition = pipes[0].getExitPosition()
					break
				pipeTransform = pipes[pipeIndex + 1].transform
				endPosition = pipes[pipeIndex + 1].getExitPosition()
				break
			pipeIndex += 1
		
		var theta = pipeTransform.get_rotation() #math acquired from https://github.com/mr-karthik-shetty/portals-2D-Unity/blob/master/PortalS.cs
		var bodyVelocity = enteringBody.velocity
		var velX = bodyVelocity.x
		var velY = bodyVelocity.y
		
		var transformedVelX = velX * cos(theta) + velY * sin(theta)
		var transformedVelY = -velX * sin(theta) + velY * cos(theta)
		
		leavingVelocity = Vector2(transformedVelX, transformedVelY)
		
		print_debug(leavingVelocity)
		GlobalSignalBus.requestPlayerPositionChange.emit(endPosition, leavingVelocity)
		
		entranceCooldown.start(1.0)



func _draw() -> void:
	if is_instance_valid(pipelinePath):
		for point in range(0, pipeline.point_count):
			var pos := pipeline.get_point_position(point)
			var circle_color: Color = Color.BLACK 
			if weightList.size() - 1 >= point:
				#circle_color.r += weightList[point] * 0.5
				circle_color.g += (weightList[point]["weight"] * 0.5) + 1
			else:
				circle_color = Color.RED
			
			if point == pipeline.point_count - 1: 
				circle_color = Color.GREEN
				if failedAttempts > 100: circle_color = Color.BLUE
				
				var movingDirection: Vector2
				if pipeline.point_count > 1:
					movingDirection = pos - pipeline.get_point_position(point - 1)
					for futurePoint in LOOKAHEAD_MAX:
						draw_circle(self.to_local(pos + (movingDirection * (futurePoint + 1))), 3.0, Color.GRAY - Color(0, 0, 0, 0.5))
			
			if debug_pipe_success == true:
				circle_color = Color.CADET_BLUE
			
			draw_circle(self.to_local(pos), 5.0, circle_color, false, 1.0)
			
			if pipeline.point_count > point + 1:
				draw_line(self.to_local(pos), self.to_local(pipeline.get_point_position(point+1)), circle_color, 4.0)


#func _process(delta: float) -> void:
	#if is_instance_valid(pipelinePath) and isCreatingPipeline == true:
		#if currentTile == dest_closestTilePos:
			##isCreatingPipeline = false
			##_finished_iterating.emit()
			#debug_pipe_success = true
			#self.queue_redraw()
			#pass
		#else:
			#debug_pipe_success = false
			#_finalize_iteration(_iterate_pipeline())
		#
		#moveCount += 1
		#
		#if failedAttempts > 100 or moveCount > (abs(entr_closestTilePos.x - dest_closestTilePos.x) * 8):
			#_initialize_iteration()
		#print(currentTile)
		#print("random chance: %.2f" % [(float(moveCount) / float(lastSuccessfulMove)) * 0.08])

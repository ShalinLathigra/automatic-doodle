extends Node

var encounter : Encounter
var map : TileMap
const TILE_SIZE = 64
const GRID_OFFSET = Vector2(TILE_SIZE/2, TILE_SIZE/2)

func set_map(m : TileMap):
	map = m
	
func set_encounter(new_encounter : Encounter):
	encounter = new_encounter

func clear_encounter():
	encounter = null
	
# world to grid coordinates
func world_to_grid(world_point : Vector2) -> Vector2:
	return map.world_to_map(world_point)
	
# convert a grid point to a world coord
func grid_to_world(grid_point : Vector2) -> Vector2:
	return map.map_to_world(grid_point) + GRID_OFFSET

# returns a world point snapped to the nearest grid point
func snap_to_grid(world_point: Vector2) -> Vector2:
	return map.map_to_world(map.world_to_map(world_point)) + GRID_OFFSET
	
# Check encounter for entities
func check_space_for_entities(_grid_origin : Vector2, _search_vector : Vector2, player_blocking : bool):
	# look at the straightline path between origin and offset
	# if any of these nodes is occupied, then the path is not clear
	#print("Entering Search: ")
	var cell = _grid_origin + _search_vector.normalized()
	return encounter.occupied_at(cell, player_blocking)
	
# Check encounter for entities
func check_path_for_entities(_grid_origin : Vector2, _move_vector : Vector2, player_blocking : bool):
	# look at the straightline path between origin and offset
	# if any of these nodes is occupied, then the path is not clear
	var dir = _move_vector.normalized()
	var cells_to_check = ceil(_move_vector.length())
	var last_good_cell = _grid_origin
	for i in range(1, cells_to_check + 1, 1):
		var cell = _grid_origin + dir * i
		if encounter.occupied_at(cell, player_blocking):
			return last_good_cell
		last_good_cell = cell
	return false
	
# objects deal with their abstraction, the grid, not the physical point
func path_obstructed(_grid_origin : Vector2, _move_vector : Vector2):
	# look at the straightline path between origin and offset
	# if any of these nodes is occupied, then the path is not clear
	var dir = _move_vector.normalized()
	var cells_to_check = ceil(_move_vector.length())
	var last_good_cell = _grid_origin
	for i in range(1, cells_to_check + 1, 1):
		var cell = _grid_origin + dir * i
		if map.get_cell(cell.x, cell.y ) > TileMap.INVALID_CELL:
			return last_good_cell
		last_good_cell = cell
	return false
	
# Checks if the motion will be valid
func movement_invalid(_grid_origin : Vector2, _grid_offset : Vector2, player_blocking : bool = true):
	var obs = path_obstructed(_grid_origin, _grid_offset)
	var ent = check_path_for_entities(_grid_origin, _grid_offset, player_blocking)
	
	if not obs and not ent:
		return false
	if obs and not ent:
		return obs
	if ent and not obs:
		return ent
		
	# nearest location to grid_origin
	var nearest = obs
	if (ent - _grid_origin).length_squared() < (obs - _grid_origin).length_squared():
		nearest = ent
		
	return nearest
	
func dir_to_player(grid_position: Vector2):
	return encounter.player.grid_position - grid_position
	
func path_to_last_player(grid_position: Vector2):
	var to_player : Vector2 = encounter.player.last_position - grid_position
	var x_dir : float = to_player.x
	var y_dir : float = to_player.y
	
	var new_dir = Vector2.ZERO
	# converting to perpendicular line. Don't care about redirects here
	if(abs(x_dir) > abs(y_dir) and x_dir != 0):
		new_dir = Vector2(x_dir / abs(x_dir), 0)
		if not movement_invalid(grid_position, new_dir):
			return new_dir
	elif y_dir != 0:
		new_dir = Vector2(0, y_dir / abs(y_dir))
		if not movement_invalid(grid_position, new_dir):
			return new_dir
	return Vector2.ZERO		
func dist_to_player(grid_position: Vector2):
	var to_player : Vector2 = encounter.player.grid_position - grid_position
	return to_player.length()

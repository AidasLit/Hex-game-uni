extends Node2D
class_name GridNavigationSystem

### grid_system should only concern the GRID
### other nodes can access the available methods
### but here there needs to be no logic for things other than the grid itself

### astar needs to store cells as integer ids
### meaning we have to extract the location from id when needed and vice versa
### 
### location from id: Vector2i(astargrid.get_point_position(id))
### id from location: cells.get(location)
### 
### note 1, astargrid.get_point_position(id) returns a Vector2, not a Vector2i
### therefore we convert it on the spot.
### 
### note 2, cells[location] can also work, but it's a getter and setter in one,
### making it possible to modify what should be an immutable value

var _visited_cells : Array[Vector2i]
var _queue_cells : Array[Vector2i]

@onready var base_layer: TileMapLayer = $"base-layer"
@onready var hover_layer: TileMapLayer = $"hover-layer"
@onready var debug_layer: TileMapLayer = $"debug-layer"
@onready var init_layer: TileMapLayer = $"init-layer"

var astargrid = AStar2D.new()
# Dictionary - Key: Vector2i, Value : int
var cells : Dictionary
var _start_cell = Vector2i(1, 1)
var dimensions : Transform2D = Transform2D(_start_cell, _start_cell, Vector2.ZERO)

func _ready() -> void:
	for cell in init_layer.get_used_cells():
		var atlas_coords = init_layer.get_cell_atlas_coords(cell)
		match Globals.init_layer_meanings[atlas_coords]:
			"start":
				_start_cell = cell
	
	await _setup_astar()
	
	for cell in base_layer.get_used_cells():
		if cell.x < dimensions.x.x:
			dimensions.x.x = cell.x
		if cell.x > dimensions.x.y:
			dimensions.x.y = cell.x
		if cell.y < dimensions.y.x:
			dimensions.y.x = cell.y
		if cell.y > dimensions.y.y:
			dimensions.y.y = cell.y

func _setup_astar():
	_visited_cells.append(_start_cell)
	astargrid.add_point(astargrid.get_available_point_id(), _start_cell)
	cells[_start_cell] = 0
	set_tile_disabled(_start_cell, false)
	
	_BFS(_start_cell)

func _BFS(current_cell : Vector2i):
	for neighbor : Vector2i in base_layer.get_surrounding_cells(current_cell):
		var cell_data = base_layer.get_cell_tile_data(neighbor)
		
		if !cell_data:
			continue
		
		if !cell_data.get_custom_data("walkable"):
			continue
		
		if !_visited_cells.has(neighbor):
			_queue_cells.append(neighbor)
			_visited_cells.append(neighbor)
			cells[neighbor] = astargrid.get_available_point_id()
			astargrid.add_point(astargrid.get_available_point_id(), neighbor)
			set_tile_disabled(neighbor, false)
		
		astargrid.connect_points(cells[neighbor], cells[current_cell])
	
	if _queue_cells:
		_BFS(_queue_cells.pop_front())

func _local_to_map(location : Vector2) -> Vector2i:
	return base_layer.local_to_map(location)

func _map_to_local(map_location : Vector2i) -> Vector2:
	return base_layer.map_to_local(map_location)

# can this cell be traveled to
func navigation_check(target_cell : Vector2i) -> bool:
	var cell_data = base_layer.get_cell_tile_data(target_cell)
	if cell_data.get_custom_data("walkable"):
		if not astargrid.is_point_disabled(cells.get(target_cell)):
			return true
	
	return false

func get_navigation_path(from : Vector2i, to : Vector2i, ignore_position: Vector2i = Vector2i.ZERO) -> Array[Vector2i]:
	# return empty path if the destination is invalid
	if not cells.has(from):
		print("no cell to navigate from (???????)", from, to)
		return []
	
	if not cells.has(to):
		print("no cell to navigate to", from, to)
		return []
	
	if from == to:
		print("trying to navigate from one position to itself", from, to)
		return []
	
	
	var from_original = astargrid.is_point_disabled(cells.get(from))
	var to_original = astargrid.is_point_disabled(cells.get(to))
	var ignore_original = false
	if ignore_position:
		ignore_original = astargrid.is_point_disabled(cells.get(ignore_position))
	
	set_tile_disabled(from, false)
	set_tile_disabled(to, false)
	if ignore_position:
		set_tile_disabled(ignore_position, false)
	
	if not navigation_check(to):
		print("cell ", to , " to navigate to not navigable, from ", from)
		return []
	
	var path = astargrid.get_id_path(cells[from], cells[to])
	
	var position_path : Array[Vector2i] = []
	
	for step : int in path:
		position_path.append(Vector2i(astargrid.get_point_position(step)))
	
	set_tile_disabled(from, from_original)
	set_tile_disabled(to, to_original)
	if ignore_position:
		set_tile_disabled(ignore_position, ignore_original)
	
	return position_path

func path_to_global_path(path : Array[Vector2i]) -> Array[Vector2]:
	var global_path : Array[Vector2] = []
	for step in path:
		global_path.append(_map_to_local(step))
	return global_path

func set_tile_disabled(tile_pos : Vector2i, disable : bool) -> void:
	astargrid.set_point_disabled(cells.get(tile_pos), disable)
	if disable:
		debug_layer.set_cell(tile_pos, 0, Globals.transparent_tile_coords["red"])
	else:
		debug_layer.set_cell(tile_pos, 0, Globals.transparent_tile_coords["green"])

func get_navigable_neighbors(from : Vector2i) -> Array[Vector2i]:
	var neighbors : Array[Vector2i] = []
	
	for tile in base_layer.get_surrounding_cells(from):
		if not base_layer.get_cell_tile_data(tile):
			continue
		
		if navigation_check(tile):
			neighbors.append(tile)
	
	return neighbors

## return a random enabled tile
func get_random_tile() -> Vector2i:
	var available_points = []
	
	for i in range(0, astargrid.get_point_count()):
		if not astargrid.is_point_disabled(i):
			available_points.append(i)
	
	var rand_id = available_points.pick_random()
	
	return Vector2i(astargrid.get_point_position(rand_id))

func is_global_pos_valid(pos : Vector2) -> bool:
	var target_cell = _local_to_map(pos)
	
	if base_layer.get_cell_atlas_coords(target_cell) == Vector2i(-1, -1):
		return false
	if !base_layer.get_cell_tile_data(target_cell).get_custom_data("walkable"):
		return false
	if astargrid.is_point_disabled(cells.get(target_cell)):
		return false
	
	return true

func get_neighbors(from : Vector2i) -> Array[Vector2i]:
	var neighbors : Array[Vector2i] = []
	
	for tile in base_layer.get_surrounding_cells(from):
		if not base_layer.get_cell_tile_data(tile):
			continue
		
		neighbors.append(tile)
	
	return neighbors

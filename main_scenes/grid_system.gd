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

@export var camera: Camera2D

@onready var base_layer: TileMapLayer = $"base-layer"
@onready var hover_layer: TileMapLayer = $"hover-layer"

var astargrid = AStar2D.new()
# Dictionary - Key: Vector2i, Value : int
var cells : Dictionary
var _start_cell = Vector2i(0, 0)

func _ready() -> void:
	_setup_astar()
	setup_camera()

func setup_camera():
	var dimensions = Vector2(21, 10)
	camera.limit_left = _map_to_local(Vector2i(0, 0)).x as int
	camera.limit_top = _map_to_local(Vector2i(0, 0)).y as int
	camera.limit_right = _map_to_local(Vector2i(dimensions.x, dimensions.y)).x as int
	camera.limit_bottom = _map_to_local(Vector2i(dimensions.x, dimensions.y)).y as int

func _setup_astar():
	_start_cell = Vector2i(0, 0)
	
	_visited_cells.append(_start_cell)
	astargrid.add_point(astargrid.get_available_point_id(), _start_cell)
	cells[_start_cell] = 0
	
	_BFS(_start_cell)
	#get_navigation_path(Vector2i(0, 0), Vector2i(0, 1))

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

func get_navigation_path(from : Vector2i, to : Vector2i, stop_next_to : bool) -> Array[Vector2i]:
	# return empty path if the destination is invalid
	if not cells.has(to):
		print("no cell to navigate to")
		return []
	
	if from == to:
		print("trying to navigate from one position to itself")
		return []
	
	#var test_path
	var allow_partial = false
	set_tile_disabled(from, false)
	
	if stop_next_to:
		set_tile_disabled(to, false)
		
		var test_path = astargrid.get_id_path(cells[from], cells[to])
		#test_path = astargrid.get_id_path(cells[from], cells[to])
		if test_path.size() == 0:
			return []
		elif to == Vector2i(astargrid.get_point_position(test_path[test_path.size() - 1])):
			# only the target tile is disabled
			allow_partial = true
		
		set_tile_disabled(to, true)
	
	if not navigation_check(to) and not allow_partial:
		print("cell ", to , " to navigate to not navigable, from ", from)
		return []
	
	var path = astargrid.get_id_path(cells[from], cells[to], allow_partial)
	var position_path : Array[Vector2i] = []
	#var test_position_path : Array[Vector2i] = []
	
	for step : int in path:
		position_path.append(Vector2i(astargrid.get_point_position(step)))
	
	#for step : int in test_path:
		#test_position_path.append(Vector2i(astargrid.get_point_position(step)))
	
	#print(test_position_path)
	#print(position_path)
	return position_path

func path_to_global_path(path : Array[Vector2i]) -> Array[Vector2]:
	var global_path : Array[Vector2] = []
	for step in path:
		global_path.append(_map_to_local(step))
	return global_path

func set_tile_disabled(tile_pos : Vector2i, disable : bool) -> void:
	astargrid.set_point_disabled(cells.get(tile_pos), disable)

func get_navigable_neighbors(from : Vector2i) -> Array[Vector2i]:
	var neighbors : Array[Vector2i] = []
	
	for tile in base_layer.get_surrounding_cells(from):
		if(not base_layer.get_cell_tile_data(tile)):
			continue
		
		if navigation_check(tile):
			neighbors.append(tile)
	
	return neighbors

## return a random enabled tile
func get_random_tile() -> Vector2i:
	var count = 0
	
	for i in range(0, astargrid.get_point_count()):
		if not astargrid.is_point_disabled(i):
			count += 1
	
	var rand_id = randi_range(0, count - 1)
	
	return Vector2i(astargrid.get_point_position(rand_id))

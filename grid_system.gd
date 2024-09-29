extends Node2D
class_name GridNavigationSystem

### grid_system should only concern the GRID
### other nodes can access the available methods
### but here there needs to be no logic for things other than the grid itself

### astar needs to store cells as integer ids
### meaning we have to extract the location from id when needed and vice versa
### 
### id to location: Vector2i(astargrid.get_point_position(id))
### location to id: cells.get(location)
### 
### note 1, astargrid.get_point_position(id) returns a Vector2, not a Vector2i
### therefore we convert it on the spot.
### 
### note 2, cells[location] can also work, but it's a getter and setter in one,
### making it possible to modify what should be an immutable value

var _visited_cells : Array[Vector2i]
var _queue_cells : Array[Vector2i]

@onready var base_layer: TileMapLayer = $"base-layer"
@onready var transparent_layer: TileMapLayer = $"transparent-layer"

var astargrid = AStar2D.new()
var cells : Dictionary

func _ready() -> void:
	cells.clear()
	_setup_astar()

func _process(delta: float) -> void:
	pass

func _setup_astar():
	var start_cell = Vector2i(0, 0)
	
	_create_cell(0, start_cell)
	
	_BFS(start_cell)

func _BFS(current_cell : Vector2i):
	for neighbor : Vector2i in base_layer.get_surrounding_cells(current_cell):
		if base_layer.get_cell_tile_data(neighbor):
			if navigation_check(neighbor):
				if !_visited_cells.has(neighbor):
					_queue_cells.append(neighbor)
					_create_cell(_visited_cells.size(), neighbor)
				
				astargrid.connect_points(cells[neighbor], cells[current_cell])
	
	if _queue_cells:
		_BFS(_queue_cells.pop_front())

func _create_cell(id : int, location : Vector2i):
	_visited_cells.append(location)
	astargrid.add_point(id, location)
	cells[location] = id

# can this cell be traveled to
func navigation_check(target_cell):
	var walkable : bool = false
	walkable = base_layer.get_cell_tile_data(target_cell).get_custom_data("walkable")
	return walkable

func get_navigation_path(from_cell : Vector2i, target_cell : Vector2i) -> Array[Vector2]:
	# return empty path is the destination is invalid
	if not cells.has(target_cell):
		#print("invalid target")
		return []
	
	var path = astargrid.get_id_path(cells[from_cell], cells[target_cell])
	var position_path : Array[Vector2] = []
	
	for step : int in path:
		position_path.append(map_to_local(astargrid.get_point_position(step)))
	
	return position_path

func local_to_map(location : Vector2):
	return base_layer.local_to_map(location)

func map_to_local(map_location : Vector2i):
	return base_layer.map_to_local(map_location)

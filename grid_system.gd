extends Node2D
class_name grid_navigation_system

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

var prev_hovered_cell : Vector2i
var hovered_cell : Vector2i

func _ready() -> void:
	cells.clear()
	_setup_astar()
	
	print(cells)

func _process(delta: float) -> void:
	_update_hovered_cell()

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

func _update_hovered_cell():
	hovered_cell = transparent_layer.local_to_map(get_viewport().get_mouse_position())
	
	if hovered_cell != prev_hovered_cell:
		transparent_layer.erase_cell(prev_hovered_cell)
	
	transparent_layer.set_cell(hovered_cell, 0, Vector2i(0, 1))
	
	prev_hovered_cell = hovered_cell

# can this cell be traveled to
func navigation_check(target_cell):
	var walkable : bool = false
	walkable = base_layer.get_cell_tile_data(target_cell).get_custom_data("walkable")
	return walkable

func get_navigation_path(from_cell : Vector2i, target_cell : Vector2i) -> Array[Vector2i]:
	# return empty path is the destination is invalid
	if not cells.has(target_cell):
		#print("invalid target")
		return []
	
	var path = astargrid.get_id_path(cells[from_cell], cells[target_cell])
	var index_path : Array[Vector2i] = []
	
	for step in path:
		index_path.append(Vector2i(astargrid.get_point_position(step)))
	
	return index_path

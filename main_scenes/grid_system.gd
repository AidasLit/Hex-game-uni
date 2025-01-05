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

@export var unit_manager : UnitManager
@export var gen_noise : NoiseTexture2D
@export var gen_grad : GradientTexture2D
@export var camera: Camera2D

@onready var base_layer: TileMapLayer = $"base-layer"
@onready var hover_layer: TileMapLayer = $"hover-layer"
@onready var availability_layer: TileMapLayer = $"availability-layer"

var astargrid = AStar2D.new()
# Dictionary - Key: Vector2i, Value : int
var cells : Dictionary

func _ready() -> void:
	_generate_map()
	
	cells.clear()
	#_setup_astar()

func _process(delta: float) -> void:
	pass

func _generate_map():
	var gradient : Image = gen_grad.get_image()
	
	var dimensions = gradient.get_size()
	var final_image = gradient.duplicate()
	
	gen_noise.noise.seed = randi()
	var noise : Image = gen_noise.noise.get_image(dimensions.x, dimensions.y)
	
	base_layer.clear()
	for x in range(0, dimensions.x):
		for y in range(0, dimensions.y):
			var noise_value = noise.get_pixel(x, y).v * gradient.get_pixel(x, y).v
			
			var temp_coords = Vector2i(x - dimensions.x/2, y - dimensions.y/2)
			base_layer.set_cell(temp_coords, 1, _get_gen_tile(noise_value))
	
	camera.limit_left = _map_to_local(Vector2i(0 - dimensions.x/2, 0 - dimensions.y/2)).x
	camera.limit_top = _map_to_local(Vector2i(0 - dimensions.x/2, 0 - dimensions.y/2)).y
	camera.limit_right = _map_to_local(Vector2i(dimensions.x/2 - 1, dimensions.y/2 - 1)).x
	camera.limit_bottom = _map_to_local(Vector2i(dimensions.x/2 - 1, dimensions.y/2 - 1)).y

func _get_gen_tile(noise_value : float):
	if noise_value <= 0:
		return Globals.solids_tile_coords["sea"]
	elif noise_value <= 0.1:
		return Globals.solids_tile_coords["shore"]
	elif noise_value <= 0.15:
		return Globals.solids_tile_coords["sand"]
	elif noise_value <= 0.4:
		return Globals.solids_tile_coords["grass"]
	elif noise_value <= 0.6:
		return Globals.solids_tile_coords["cliff"]
	elif noise_value <= 0.8:
		return Globals.solids_tile_coords["mountain"]
	else:
		return Globals.solids_tile_coords["snow"]

func _setup_astar():
	var start_cell = Vector2i(0, 0)
	
	_create_cell(0, start_cell)
	
	_BFS(start_cell)

func _BFS(current_cell : Vector2i):
	for neighbor : Vector2i in base_layer.get_surrounding_cells(current_cell):
		if base_layer.get_cell_tile_data(neighbor):
			if _nav_setup_check(neighbor):
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

func _local_to_map(location : Vector2) -> Vector2i:
	return base_layer.local_to_map(location)

func _map_to_local(map_location : Vector2i) -> Vector2:
	return base_layer.map_to_local(map_location)

func _nav_setup_check(target_cell : Vector2i) -> bool:
	var cell_data = base_layer.get_cell_tile_data(target_cell)
	if cell_data.get_custom_data("walkable"):
		return true
	
	return false

# can this cell be traveled to
func navigation_check(target_cell : Vector2i) -> bool:
	var cell_data = base_layer.get_cell_tile_data(target_cell)
	if cell_data.get_custom_data("walkable"):
		if not astargrid.is_point_disabled(cells.get(target_cell)):
			return true
	
	return false

func get_navigation_path(from : Vector2i, to : Vector2i) -> Array[Vector2i]:
	#var from_cell = _local_to_map(from)
	#var target_cell = _local_to_map(to)
	
	# return empty path is the destination is invalid
	if not cells.has(to):
		#print("invalid target")
		return []
	
	if not navigation_check(to):
		return []
	
	var path = astargrid.get_id_path(cells[from], cells[to])
	var position_path : Array[Vector2i] = []
	
	for step : int in path:
		position_path.append(Vector2i(astargrid.get_point_position(step)))
	
	return position_path

func path_to_global_path(path : Array[Vector2i]) -> Array[Vector2]:
	var global_path : Array[Vector2] = []
	for step in path:
		global_path.append(_map_to_local(step))
	return global_path

# TODO this needs a rework
func set_tile_disabled(tile_pos : Vector2i, disable : bool) -> void:
	astargrid.set_point_disabled(cells.get(tile_pos), disable)

func set_attackability(unit : PlayableUnit) -> void:
	var available_points : Array[int] = []
	var available_tiles : Array[Vector2i] = []
	
	var unit_tile_id : int = cells.get(unit.tilemap_position)
	
	for neighbor : int in astargrid.get_point_connections(unit_tile_id):
		var temp_pos = Vector2i(astargrid.get_point_position(neighbor))
		
		if unit_manager.map_of_units.has(temp_pos):
			if unit_manager.map_of_units[temp_pos].unit_owner == Globals.UnitOwner.Rogue or\
				unit_manager.map_of_units[temp_pos].unit_owner != unit.unit_owner:
				if !available_points.has(neighbor):
					available_points.append(neighbor)
	
	#points -> tiles translation
	for point : int in available_points:
		var tile = Vector2i(astargrid.get_point_position(point))
		available_tiles.append(tile)
	
	availability_layer.draw_attackability(available_tiles)

func set_availability(unit : PlayableUnit) -> void:
	var available_tiles = unit.unit_res.movement.get_available_tiles(self)

	availability_layer.clear()
	availability_layer.draw_movability(available_tiles)
	set_attackability(unit)
	availability_layer.set_cell(unit.tilemap_position, 0, Globals.transparent_tile_coords["pink"])

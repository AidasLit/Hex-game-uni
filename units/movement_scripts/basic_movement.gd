extends UnitMovement

static func get_available_tiles(grid_system : GridNavigationSystem) -> Array[Array]:
	var available_points : Array[int] = []
	var available_tiles : Array[Array] = [[unit.tilemap_position]]
	available_tiles.resize(unit.movement_range)
	
	for i in unit.movement_range:
		available_tiles[i] = _cycle_neighbors(available_points, available_tiles[i], grid_system)
	
	return available_tiles

static func _cycle_neighbors(available_points : Array[int], current_level : Array, grid_system) -> Array[Vector2i]:
	var neighbors : Array[Vector2i] = []
	for tile : Vector2i in current_level:
		for neighbor : int in grid_system.astargrid.get_point_connections(grid_system.cells[tile]):
			var cell_data
			if grid_system.navigation_check(Vector2i(grid_system.astargrid.get_point_position(neighbor))):
				if !available_points.has(neighbor):
					available_points.append(neighbor)
					neighbors.append(Vector2i(grid_system.astargrid.get_point_position(neighbor)))
	return neighbors

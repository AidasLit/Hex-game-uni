extends Node2D

@onready var base_layer: TileMapLayer = $"base-layer"
var astargrid = AStar2D.new()
var visited_cells : Array[Vector2i]
var cell_queue : Array[Vector2i]

func _ready() -> void:
	setup_astar()

func _process(delta: float) -> void:
	pass

# only BFS done, just need to take the results and create the graph for astar
func setup_astar():
	var start_cell = Vector2i(-1, -1)
	
	visited_cells.append(start_cell)
	BFS(start_cell)
	print(visited_cells)
	
	for node : Vector2i in visited_cells:
		base_layer.set_cell(node, 1, Vector2i(2, 1))

func BFS(current_cell : Vector2i):
	for neighbor : Vector2i in base_layer.get_surrounding_cells(current_cell):
		if base_layer.get_cell_tile_data(neighbor):
			if base_layer.get_cell_tile_data(neighbor).get_custom_data("walkable"):
				if !visited_cells.has(neighbor):
					visited_cells.append(neighbor)
					cell_queue.append(neighbor)
	
	if cell_queue:
		BFS(cell_queue.pop_front())

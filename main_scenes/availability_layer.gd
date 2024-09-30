extends TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func draw_availability(list : Array[Vector2i]) -> void:
	clear()
	
	for tile : Vector2i in list:
		set_cell(tile, 0, Globals.transparent_tile_coords["green"])

func is_available(cell : Vector2i) -> bool:
	var data = get_cell_tile_data(cell)
	if data:
		if data.texture_origin == Globals.transparent_tile_coords["green"]:
			return true
	return false
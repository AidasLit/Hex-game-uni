extends TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func draw_movability(list : Array[Array]) -> void:
	for layer in list.size():
		if layer == list.size() - 1:
			for tile in list[layer]:
				set_cell(tile, 0, Globals.transparent_tile_coords["orange"])
		else:
			for tile in list[layer]:
				set_cell(tile, 0, Globals.transparent_tile_coords["green"])

func draw_attackability(list : Array[Vector2i]) -> void:
	for tile : Vector2i in list:
		set_cell(tile, 0, Globals.transparent_tile_coords["red"])

func is_actionable(cell : Vector2i) -> Globals.ActionType:
	var data = get_cell_tile_data(cell)
	
	if data:
		match get_cell_atlas_coords(cell):
			Globals.transparent_tile_coords["green"]:
				return Globals.ActionType.Movement
			Globals.transparent_tile_coords["orange"]:
				return Globals.ActionType.Movement
			Globals.transparent_tile_coords["red"]:
				return Globals.ActionType.Attack
	
	return Globals.ActionType.None

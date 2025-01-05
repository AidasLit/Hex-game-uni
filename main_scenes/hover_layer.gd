extends TileMapLayer

@export var camera : Camera2D

var hovered_cell : Vector2i
var prev_hovered_cell : Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_update_hovered_cell()

func _update_hovered_cell():
	hovered_cell = self.local_to_map(camera.get_global_mouse_position())
	
	if hovered_cell != prev_hovered_cell:
		self.erase_cell(prev_hovered_cell)
		self.set_cell(hovered_cell, 0, Globals.transparent_tile_coords["white"])
	
	prev_hovered_cell = hovered_cell

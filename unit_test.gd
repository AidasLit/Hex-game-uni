extends CharacterBody2D

@export var tilemap_layer: TileMapLayer
@export var grid_system: grid_navigation_system

var current_cell : Vector2i


func _ready() -> void:
	goto_cell(Vector2i(0, 0))

# self documenting code amirite
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			# local_to_map translates our mouse click position into a tilemap position
			var target_cell : Vector2i = tilemap_layer.local_to_map(event.position)
			
			var path = grid_system.get_navigation_path(current_cell, target_cell)
			
			if not path.is_empty():
				travel_path(path)

func travel_path(path):
	for next_step in path:
		# await needs to happen inside this loop
		# if it's in a seperate function, the looped functions will be executed in parallel, which is not what we want
		var tween = get_tree().create_tween()
		tween.tween_property(self, "global_position", tilemap_layer.map_to_local(next_step), 0.1)
		await tween.finished
		
		current_cell = next_step

# travels to a cell, for singular use only
func goto_cell(target : Vector2i):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", tilemap_layer.map_to_local(target), 0.2)
	await tween.finished
	
	current_cell = target

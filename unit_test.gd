extends CharacterBody2D

@export var tilemap_layer: TileMapLayer

# self documenting code amirite
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			var target_pos = get_pressed_tile_pos(event.position)
			
			# tween is animation stuffs, temporary code here
			var tween = get_tree().create_tween()
			tween.tween_property(self, "global_position", target_pos, 0.5)

# ignore this, it's for physics stuff
func _physics_process(delta: float) -> void:
	pass

func get_pressed_tile_pos(press_location: Vector2) -> Vector2:
	# gets tile position of within the tilemap (works somewhat like an index)
	# tilemap position =/= global position
	var tile_pos = tilemap_layer.local_to_map(press_location)
	
	# if tile exists on clicked location, we go there.
	# otherwise we stay in the current location
	var tile = tilemap_layer.get_cell_tile_data(tile_pos)
	if tile:
		# if tile is walkable, we go there.
		# otherwise we stay in the current location
		if tile.get_custom_data("walkable"):
			return tilemap_layer.map_to_local(tile_pos)
		else:
			#TODO bad practice or something
			return self.global_position
	else:
		#TODO bad practice or something
		return self.global_position

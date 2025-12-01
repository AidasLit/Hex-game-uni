extends Node2D
class_name UnitManager

### Manages unit actions
### No gameplay actions, only receiving commands and making units perform them

const playable_unit_scene = preload("res://units/playable_unit.tscn")

@export var play_loop: Node2D
@export var grid_system: GridNavigationSystem

signal action_done
signal unit_placed(successful : bool)
func call_unit_placed(successful : bool):
	# TODO for some reason signal doesnt get caught the first time it's used
	# unless it's being called in a deferred mode. lookup more of
	# https://www.reddit.com/r/godot/comments/p6jm0s/are_signals_called_inline_or_are_they_deferred_in/
	#unit_placed.emit(successful)
	(func(): unit_placed.emit(successful)).call_deferred()

var map_of_units : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func try_place_unit(at_position : Vector2):
	var target_cell = grid_system._local_to_map(at_position)
	
	if grid_system.base_layer.get_cell_atlas_coords(target_cell) == Vector2i(-1, -1) or  \
	!grid_system.base_layer.get_cell_tile_data(target_cell).get_custom_data("walkable") or \
	grid_system.astargrid.is_point_disabled(grid_system.cells.get(target_cell)):
		call_unit_placed(false)
		return
	
	var unit : PlayableUnit = playable_unit_scene.instantiate()
	self.add_child(unit)
	
	unit.tilemap_position = target_cell
	unit.global_position = grid_system._map_to_local(unit.tilemap_position)
	unit.kill_me.connect(kill_unit)
	
	grid_system.set_tile_disabled(unit.tilemap_position, true)
	map_of_units[unit.tilemap_position] = unit
	
	play_loop.unit_list.push_back(unit)
	play_loop.action_queue.push_back(unit)
	
	call_unit_placed(true)

func kill_unit(unit : PlayableUnit):
	#remove old positions
	map_of_units.erase(unit.tilemap_position)
	grid_system.set_tile_disabled(unit.tilemap_position, false)
	
	#delete unit
	play_loop.unit_list.erase(unit)
	play_loop.action_queue.erase(unit)
	unit.queue_free()

func move_unit(unit : PlayableUnit, move_to : Vector2i) -> void:
	#get path
	var path = grid_system.get_navigation_path(unit.tilemap_position, move_to)
	path.pop_front()
	
	#remove old positions
	map_of_units.erase(unit.tilemap_position)
	grid_system.set_tile_disabled(unit.tilemap_position, false)
	
	#traverse
	unit.travel_path(grid_system.path_to_global_path(path))
	await unit.done_moving
	
	#update unit
	unit.tilemap_position = path.back()
	unit.movement_range -= path.size()
	
	#add new positions
	map_of_units[unit.tilemap_position] = unit
	grid_system.set_tile_disabled(unit.tilemap_position, true)
	
	action_done.emit()

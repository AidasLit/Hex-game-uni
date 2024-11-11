extends Node2D
class_name UnitManager

### Manages unit actions
### No gameplay actions, only receiving commands and making units perform them

const playable_unit_scene = preload("res://units/playable_unit.tscn")

@export var play_loop: Node2D
@export var grid_system: GridNavigationSystem
@export var hud: HUD

signal action_done
signal setup_done

var map_of_units : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func setup_units() -> void:
	hud.show_deployable_units()
	
	await hud.deployment_finished
	
	play_loop.active_unit = play_loop.action_queue.pop_front()
	#await play_loop.active_unit.done_moving
	grid_system.set_availability(play_loop.active_unit)
	
	setup_done.emit()

func place_unit(unit_id : int, at_position : Vector2, unit_owner : Globals.UnitOwner):
	var target_cell = grid_system._local_to_map(at_position)
	if !grid_system.base_layer.get_cell_tile_data(target_cell).get_custom_data("walkable"):
		return
	
	
	var unit = playable_unit_scene.instantiate()
	self.add_child(unit)
	
	unit.unit_res = Globals.unit_types[unit_id].duplicate()
	unit.setup()
	
	unit.unit_owner = unit_owner
	unit.tilemap_position = target_cell
	map_of_units[unit.tilemap_position] = unit
	unit.kill_me.connect(kill_unit)
	play_loop.action_queue.push_back(unit)
	grid_system.set_tile_disabled(unit.tilemap_position, true)
	
	unit.global_position = grid_system._map_to_local(unit.tilemap_position)

func kill_unit(unit : PlayableUnit):
	#remove old positions
	map_of_units.erase(unit.tilemap_position)
	grid_system.set_tile_disabled(unit.tilemap_position, false)
	
	#delete unit
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
	grid_system.set_availability(unit)
	
	action_done.emit()

extends Node2D
class_name UnitManager

@export var grid_system: GridNavigationSystem
@export var play_loop: Node2D

### Manages unit actions
### No gameplay actions, only receiving commands and making units perform them

signal action_done
signal setup_done

var map_of_units : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func setup_units() -> void:
	var RNG = RandomNumberGenerator.new()
	var i = RNG.randi_range(0, grid_system.astargrid.get_point_count()/3)
	
	for unit : PlayableUnit in get_tree().get_nodes_in_group("unit"):
		unit.unit_res = load("res://units/unit_type_resources/solider.tres")
		
		var start_location = grid_system._map_to_local(Vector2i(grid_system.astargrid.get_point_position(i)))
		
		if i % 3 == 1:
			unit.unit_owner = Globals.UnitOwner.Player
			unit.modulate = Color(0, 1, 0)
		elif i % 3 == 2:
			unit.unit_owner = Globals.UnitOwner.Enemy
			unit.modulate = Color(1, 0, 0)
		else:
			unit.unit_owner = Globals.UnitOwner.Rogue
			unit.modulate = Color(0, 0, 1)
		
		unit.goto_location(start_location)
		unit.tilemap_position = Vector2i(grid_system.astargrid.get_point_position(i))
		map_of_units[unit.tilemap_position] = unit
		unit.kill_me.connect(kill_unit)
		play_loop.action_queue.push_back(unit)
		
		grid_system.set_tile_disabled(unit.tilemap_position, true)
		i += RNG.randi_range(1, grid_system.astargrid.get_point_count()/3 - 1)
	
	play_loop.active_unit = play_loop.action_queue.pop_front()
	await play_loop.active_unit.done_moving
	grid_system.set_availability(play_loop.active_unit)
	
	setup_done.emit()

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

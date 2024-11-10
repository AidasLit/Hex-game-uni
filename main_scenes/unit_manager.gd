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
	for unit_id in SaveState.units:
		var unit = playable_unit_scene.instantiate()
		self.add_child(unit)
		unit.hide()
		
		unit.unit_res = Globals.unit_types[unit_id].duplicate()
		unit.setup()
		
		## this should be done manually based on player input
		#unit.tilemap_position = Vector2i(grid_system.astargrid.get_point_position(i))
		#map_of_units[unit.tilemap_position] = unit
		#unit.kill_me.connect(kill_unit)
		#play_loop.action_queue.push_back(unit)
		#grid_system.set_tile_disabled(unit.tilemap_position, true)
		#unit.show()
	
	hud.show_deployable_units()
	
	play_loop.active_unit = play_loop.action_queue.pop_front()
	#await play_loop.active_unit.done_moving
	#grid_system.set_availability(play_loop.active_unit)
	
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

extends Node2D
class_name UnitManager

### Manages unit actions
### No gameplay actions, only receiving commands and making units perform them

const playable_unit_scene = preload("res://units/playable_unit.tscn")
const tree_scene = preload("uid://blmdyywmffl20")

func call_unit_placed(successful : bool):
	# TODO for some reason signal doesnt get caught the first time it's used
	# unless it's being called in a deferred mode. lookup more of
	# https://www.reddit.com/r/godot/comments/p6jm0s/are_signals_called_inline_or_are_they_deferred_in/
	#unit_placed.emit(successful)
	(func(): SignalBus.unit_placed.emit(successful)).call_deferred()

var map_of_units : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.kill_me.connect(kill_unit)

func try_place_unit(at_position : Vector2):
	if not Globals.grid_system.is_global_pos_valid(at_position):
		call_unit_placed(false)
		return
	
	var unit : PlayableUnit = playable_unit_scene.instantiate()
	self.add_child(unit)
	
	unit.tilemap_position = Globals.grid_system._local_to_map(at_position)
	unit.global_position = Globals.grid_system._map_to_local(unit.tilemap_position)
	
	#unit.agent.world_node = GdPAIUTILS.get_child_of_type(get_tree().root, GdPAIWorldNode)
	#unit.agent.goals.append(WanderGoal.new())
	#unit.agent.goals.append(ChopTreesGoal.new())
	#unit.agent.self_actions.append(WanderAction.new())
	
	Globals.grid_system.set_tile_disabled(unit.tilemap_position, true)
	map_of_units[unit.tilemap_position] = unit
	
	Globals.play_loop.unit_list.push_back(unit)
	Globals.play_loop.action_queue.push_back(unit)
	
	call_unit_placed(true)

func kill_unit(unit):
	if unit is PlayableUnit:
		map_of_units.erase(unit.tilemap_position)
		
		Globals.play_loop.unit_list.erase(unit)
		Globals.play_loop.action_queue.erase(unit)
	elif unit is TreeObject:
		pass
	
	Globals.grid_system.set_tile_disabled(unit.tilemap_position, false)
	#delete unit
	unit.queue_free()

func move_unit(unit : PlayableUnit, move_to : Vector2i, stop_next_to : bool) -> void:
	#remove old positions
	map_of_units.erase(unit.tilemap_position)
	#grid_system.set_tile_disabled(unit.tilemap_position, false)
	
	#get path
	var path = Globals.grid_system.get_navigation_path(unit.tilemap_position, move_to, stop_next_to)
	path.pop_front()
	
	#traverse
	unit.travel_path(Globals.grid_system.path_to_global_path(path))
	#await unit.done_moving
	
	#update unit
	unit.tilemap_position = path.back()
	unit.movement_range -= path.size()
	
	#add new positions
	map_of_units[unit.tilemap_position] = unit
	Globals.grid_system.set_tile_disabled(unit.tilemap_position, true)

func chop_tree(unit : PlayableUnit, tree_position : Vector2i):
	var tree : TreeObject = map_of_units[tree_position]
	
	tree.chopped()
	
	unit.nudge_attack(tree_position)
	
	map_of_units.erase(tree_position)
	Globals.grid_system.set_tile_disabled(tree_position, false)

func generate_tree():
	var tilemap_position = Globals.grid_system.get_random_tile()
	
	var tree : TreeObject = tree_scene.instantiate()
	self.add_child(tree)
	
	tree._data_init(tilemap_position)
	tree.global_position = Globals.grid_system._map_to_local(tilemap_position)
	
	map_of_units[tilemap_position] = tree
	
	Globals.grid_system.set_tile_disabled(tilemap_position, true)
	var tree_count = Globals.world_blackboard.get_property("tree_count")
	Globals.world_blackboard.set_property("tree_count", tree_count + 1)

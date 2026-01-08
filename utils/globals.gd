extends Node

var play_loop : PlayLoop
var grid_system : GridNavigationSystem
var hud : HUD
var camera : Camera2D

var world_blackboard : GdPAIBlackboard

#region object maps
var map_of_units : Dictionary = {}
var map_of_spaces : Dictionary = {}

func register_unit(unit):
	map_of_units[unit.tilemap_position] = unit
	grid_system.set_tile_disabled(unit.tilemap_position, true)

func register_space(space):
	map_of_spaces[space.tilemap_position] = space

func unregister_unit(unit):
	map_of_units.erase(unit.tilemap_position)
	grid_system.set_tile_disabled(unit.tilemap_position, false)
	
	if unit is PlayableUnit:
		play_loop.unit_list.erase(unit)

func unregister_space(space):
	map_of_spaces.erase(space.tilemap_position)

func relocate_unit(unit, to : Vector2i):
	map_of_units.erase(unit.tilemap_position)
	grid_system.set_tile_disabled(unit.tilemap_position, false)
	
	map_of_units[to] = unit
	grid_system.set_tile_disabled(to, true)
#endregion

#region preconditions
func get_navigable_check(target: Node2D) -> Precondition:
	var can_get_to: Precondition = Precondition.new()
	can_get_to.eval_func = func(blackboard: GdPAIBlackboard, _world_state: GdPAIBlackboard):
		var agent_position: Vector2i = blackboard.get_property("tilemap_position")
		
		var path = Globals.grid_system.get_navigation_path(agent_position, target.tilemap_position)
		
		return not path.is_empty()
	return can_get_to

func get_standing_next_to_check(target: Node2D) -> Precondition:
	var standing_next_to: Precondition = Precondition.new()
	standing_next_to.eval_func = func(blackboard: GdPAIBlackboard, _world_state: GdPAIBlackboard):
		var blackboard_agent_position = blackboard.get_property("tilemap_position")
		
		var available_neighbors = Globals.grid_system.get_neighbors(target.tilemap_position)
		
		return available_neighbors.has(blackboard_agent_position)
	return standing_next_to

func get_standing_on_check(target: Node2D) -> Precondition:
	var standing_on: Precondition = Precondition.new()
	standing_on.eval_func = func(blackboard: GdPAIBlackboard, _world_state: GdPAIBlackboard):
		var blackboard_agent_position = blackboard.get_property("tilemap_position")
		
		return blackboard_agent_position == target.tilemap_position
	return standing_on
#endregion

const agent_action_time = 0.1

const tree_count = 10
const heal_count = 2
const thorn_count = 3

const transparent_tile_coords : Dictionary = {
	"green": Vector2i(0, 0),
	"red": Vector2i(1, 0),
	"blue": Vector2i(2, 0),
	"yellow": Vector2i(3, 0),
	"white": Vector2i(0, 1),
	"pink": Vector2i(1, 1),
	"brown": Vector2i(2, 1),
	"orange": Vector2i(3, 1)
}

const solids_tile_coords : Dictionary = {
	"grass": Vector2i(0, 0),
	"sand": Vector2i(1, 0),
	"shore": Vector2i(2, 0),
	"sea": Vector2i(3, 0),
	"cliff": Vector2i(0, 1),
	"mountain": Vector2i(1, 1),
	"snow": Vector2i(2, 1),
	"magma": Vector2i(3, 1)
}

const init_layer_meanings : Dictionary = {
	transparent_tile_coords["green"]: "start",
	transparent_tile_coords["red"]: "bonfire"
}

enum ActionType {
	None,
	Movement,
	Attack
}

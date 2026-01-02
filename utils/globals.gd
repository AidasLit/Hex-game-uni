extends Node

var play_loop : PlayLoop
var grid_system : GridNavigationSystem
var hud : HUD
var camera : Camera2D

#region unit map
var map_of_units : Dictionary

func register_unit(unit):
	map_of_units[unit.tilemap_position] = unit
	grid_system.set_tile_disabled(unit.tilemap_position, true)

func unregister_unit(unit):
	map_of_units.erase(unit.tilemap_position)
	grid_system.set_tile_disabled(unit.tilemap_position, false)
	
	if unit is PlayableUnit:
		play_loop.unit_list.erase(unit)
		play_loop.action_queue.erase(unit)

func relocate_unit(unit, to : Vector2i):
	map_of_units.erase(unit.tilemap_position)
	grid_system.set_tile_disabled(unit.tilemap_position, false)
	
	map_of_units[to] = unit
	grid_system.set_tile_disabled(to, true)
#endregion

var world_blackboard : GdPAIBlackboard

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

enum ActionType {
	None,
	Movement,
	Attack
}

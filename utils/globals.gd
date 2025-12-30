extends Node

var play_loop : PlayLoop
var grid_system : GridNavigationSystem
var hud : HUD
var camera : Camera2D

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

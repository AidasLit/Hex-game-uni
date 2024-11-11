extends Node

enum UnitOwner {
	Player,
	Enemy,
	Rogue
}

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

enum ActionType {
	None,
	Movement,
	Attack
}

### preload doesnt work here, cyclical dependancy (I have no clue wtf is wrong with it)
var unit_types : Array[PlayableUnitRes]= [
	load("res://units/unit_type_resources/solider.tres"),
	load("res://units/unit_type_resources/hunter.tres")
]

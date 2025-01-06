extends Node

### array of ids. 
var player_units : Array[int] = []
var enemy_units : Array[int] = []

func _ready() -> void:
	player_units.append(0)
	player_units.append(0)
	player_units.append(1)
	player_units.append(1)
	
	enemy_units.append(0)
	enemy_units.append(0)
	enemy_units.append(1)
	enemy_units.append(1)

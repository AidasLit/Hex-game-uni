class_name TreeObject
extends Node2D

@onready var tree_object_data: TreeObjectData = $TreeObjectData

signal kill_me(self_ref)

func _data_init(play_loop : Node2D, grid_system : GridNavigationSystem, tilemap_position : Vector2i) -> void:
	tree_object_data.play_loop = play_loop
	tree_object_data.grid_system = grid_system
	tree_object_data.tilemap_position = tilemap_position

func chopped():
	kill_me.emit(self)

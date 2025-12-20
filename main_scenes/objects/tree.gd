class_name TreeObject
extends Node2D

@onready var tree_object_data: TreeObjectData = $TreeObjectData

var tilemap_position: Vector2i

func _data_init(_tilemap_position : Vector2i) -> void:
	tilemap_position = _tilemap_position
	tree_object_data.tilemap_position = _tilemap_position

func chopped():
	var tree_count = Globals.world_blackboard.get_property("tree_count")
	Globals.world_blackboard.set_property("tree_count", tree_count - 1)
	SignalBus.kill_me.emit(self)

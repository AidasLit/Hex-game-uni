class_name WoodObject
extends Node2D

@onready var wood_object_data: WoodObjectData = $WoodObjectData
@onready var sprite: Sprite2D = $Sprite2D

var tilemap_position: Vector2i

func _init() -> void:
	var free_wood_count = Globals.world_blackboard.get_property("free_wood_count")
	Globals.world_blackboard.set_property("free_wood_count", free_wood_count + 1)
	
	var total_wood_count = Globals.world_blackboard.get_property("total_wood_count")
	Globals.world_blackboard.set_property("total_wood_count", total_wood_count + 1)

func _data_init(_tilemap_position : Vector2i) -> void:
	tilemap_position = _tilemap_position
	wood_object_data.tilemap_position = _tilemap_position

func taken():
	var free_wood_count = Globals.world_blackboard.get_property("free_wood_count")
	Globals.world_blackboard.set_property("free_wood_count", free_wood_count - 1)
	
	Globals.unregister_unit(self)
	SignalBus.unit_killed.emit(self)
	self.queue_free()

class_name WoodObject
extends Node2D

@onready var wood_object_data: WoodObjectData = $WoodObjectData
@onready var sprite: Sprite2D = $Sprite2D

var tilemap_position: Vector2i

func _init() -> void:
	var wood_count = Globals.world_blackboard.get_property("wood_count")
	Globals.world_blackboard.set_property("wood_count", wood_count + 1)

func _data_init(_tilemap_position : Vector2i) -> void:
	tilemap_position = _tilemap_position
	wood_object_data.tilemap_position = _tilemap_position

func taken():
	var wood_count = Globals.world_blackboard.get_property("wood_count")
	Globals.world_blackboard.set_property("wood_count", wood_count - 1)
	
	## TODO WHY WONT YOU DIE
	Globals.unregister_unit(self)
	SignalBus.unit_killed.emit(self)
	self.queue_free()

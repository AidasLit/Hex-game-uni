class_name HealthSpace
extends Node2D

@onready var health_space_data: HealthSpaceData = $HealthSpaceData

var tilemap_position: Vector2i

func _data_init(_tilemap_position : Vector2i) -> void:
	tilemap_position = _tilemap_position
	health_space_data.tilemap_position = _tilemap_position

func effect(unit : PlayableUnit):
	unit.health_component.receive_damage(-80)

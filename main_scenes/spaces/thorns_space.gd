class_name ThornsSpace
extends Node2D

var tilemap_position: Vector2i

func _data_init(_tilemap_position : Vector2i) -> void:
	tilemap_position = _tilemap_position

func effect(unit : PlayableUnit):
	unit.health_component.receive_damage(30)

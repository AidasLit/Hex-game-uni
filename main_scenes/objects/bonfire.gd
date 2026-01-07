class_name BonfireObject
extends Node2D

@onready var bonfire_object_data: BonfireObjectData = $BonfireObjectData
@onready var health_component: HealthComponent = $HealthComponent

var fire_strength = 100
var tilemap_position: Vector2i

func _ready() -> void:
	health_component._max_hp = fire_strength
	health_component.reset_hp()
	
	health_component.zero_hp.connect(stop_burning)
	health_component.hp_changed.connect(func(value): 
		Globals.world_blackboard.set_property("fire_strength", value)
	)

func _data_init(_tilemap_position : Vector2i) -> void:
	tilemap_position = _tilemap_position
	Globals.bonfire_position = _tilemap_position
	bonfire_object_data.tilemap_position = _tilemap_position

func tick():
	health_component.receive_damage(1)

func feed():
	health_component.receive_damage(-20)

func stop_burning():
	## TODO WHY WONT YOU DIE
	Globals.unregister_unit(self)
	SignalBus.unit_killed.emit(self)
	SignalBus.game_over.emit()
	self.queue_free()

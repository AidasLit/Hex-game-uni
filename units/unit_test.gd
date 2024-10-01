extends CharacterBody2D
class_name PlayableUnit

@onready var health_component: HealthComponent = $HealthComponent

# temporary variable for debugging
@export var my_name: String = "blank"
@export var max_hp: int = 10
@export var max_range: int = 3

signal done_moving

var movement_range : int
var unit_owner : Globals.UnitOwner

func _ready() -> void:
	health_component.max_hp = max_hp
	turn_reset()

func travel_path(path : Array[Vector2]):
	for next_step : Vector2 in path:
		# await needs to happen inside this loop
		# if it's in a seperate function, the looped functions will be executed in parallel, which is not what we want
		var tween = get_tree().create_tween()
		tween.tween_property(self, "global_position", next_step, 0.1)
		await tween.finished
		
		await get_tree().create_timer(0.1).timeout
	
	done_moving.emit()

# travels to a cell, for singular use only
func goto_location(target : Vector2):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", target, 0.2)
	await tween.finished
	
	done_moving.emit()

func turn_reset() -> void:
	movement_range = max_range

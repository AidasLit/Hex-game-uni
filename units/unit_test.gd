extends CharacterBody2D
class_name PlayableUnit

@export var tilemap_layer: TileMapLayer
@export var grid_system: GridNavigationSystem
# temporary variable for debugging
@export var my_name: String
@export var movement_range: int

signal done_moving

var unit_owner : Globals.UnitOwner

func _ready() -> void:
	pass

func travel_path(path : Array[Vector2]):
	for next_step : Vector2 in path:
		# await needs to happen inside this loop
		# if it's in a seperate function, the looped functions will be executed in parallel, which is not what we want
		var tween = get_tree().create_tween()
		tween.tween_property(self, "global_position", next_step, 0.1)
		await tween.finished
	
	done_moving.emit()

# travels to a cell, for singular use only
func goto_location(target : Vector2):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", target, 0.2)
	await tween.finished
	
	done_moving.emit()

extends CharacterBody2D
class_name PlayableUnit

### All logic that is shared by all units
### Individual logic goes into resources

@onready var health_component: HealthComponent = $HealthComponent
@onready var base_texture: Sprite2D = $Sprite2D
@onready var speed_label: Label = $Label

@export var unit_res: PlayableUnitRes

signal setup_done
signal done_moving
signal attack_finished
signal kill_me(unit_ref)

var tilemap_position : Vector2i
# TODO move the movement logic to the resource
var movement_range : int
var unit_owner : Globals.UnitOwner

func _ready() -> void:
	health_component.zero_hp.connect(_on_zero_hp)

# setup for resource stuff, has to be called by the unit manager
func setup() -> void:
	unit_res.setup(self)
	base_texture.texture = unit_res.sprite
	health_component.max_hp = unit_res.max_hp
	
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

func nudge_attack(target : Vector2):
	var return_pos = global_position
	var direction = (target - global_position).normalized()
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", return_pos + direction * 50, 0.1)
	tween.tween_property(self, "global_position", return_pos, 0.2)
	await tween.finished
	
	attack_finished.emit()

func turn_reset() -> void:
	movement_range = unit_res.movement_range
	unit_res.reset_speed_counter()
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.3)

func _on_zero_hp() -> void:
	kill_me.emit(self)

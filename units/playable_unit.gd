extends CharacterBody2D
class_name PlayableUnit

### All logic that is shared by all units
### Individual logic goes into resources

@onready var health_component: HealthComponent = $HealthComponent
@onready var base_texture: Sprite2D = $Sprite2D

@export var id : int
@export var sprite : CompressedTexture2D
@export var my_name : String
@export var max_hp : int
@export var damage : int
@export var max_movement_range : int

signal done_moving
signal attack_finished
signal kill_me(unit_ref)

var tilemap_position : Vector2i
var movement_range : int

var is_active = false : 
	set(value):
		var tween = get_tree().create_tween()
		if value:
			tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.3)
		else:
			tween.tween_property(self, "scale", Vector2.ONE, 0.3)
		is_active = value

func _ready() -> void:
	health_component.zero_hp.connect(_on_zero_hp)
	
	health_component.max_hp = max_hp
	base_texture.texture = sprite
	health_component.reset_hp()
	
	turn_reset()

func travel_path(path : Array[Vector2]):
	for next_step : Vector2 in path:
		sprite_flip(next_step)
		
		# await needs to happen inside this loop
		# if it's in a seperate function, the looped functions will be executed in parallel, which is not what we want
		var tween = get_tree().create_tween()
		tween.tween_property(self, "global_position", next_step, 0.1)
		await tween.finished
		
		await get_tree().create_timer(0.1).timeout
	
	done_moving.emit()

# travels to a cell, for singular use only
func goto_location(target : Vector2):
	sprite_flip(target)
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", target, 0.2)
	await tween.finished
	
	done_moving.emit()

func nudge_attack(target : Vector2):
	var return_pos = global_position
	var direction = (target - global_position).normalized()
	
	sprite_flip(target)
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", return_pos + direction * 50, 0.1)
	tween.tween_property(self, "global_position", return_pos, 0.2)
	await tween.finished
	
	attack_finished.emit()

func turn_reset() -> void:
	movement_range = max_movement_range

func _on_zero_hp() -> void:
	kill_me.emit(self)

func sprite_flip(next_step : Vector2):
	if next_step.x > global_position.x:
		base_texture.flip_h = true
	elif next_step.x < global_position.x:
		base_texture.flip_h = false

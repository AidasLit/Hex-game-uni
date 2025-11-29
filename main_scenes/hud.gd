extends CanvasLayer
class_name HUD

@export var camera : Camera2D

@onready var unit_manager: UnitManager = $"../unit-manager"
@onready var begin_button: Button = $"begin-button"
@onready var current_owner: Label = $"current-owner"
@onready var game_over: Label = $"game-over"
@onready var unit_stats: StatsDisplay = $"PanelContainer/MarginContainer/unit-stats"

@onready var deployable_units_container: VBoxContainer = $MarginContainer/Panel/VBoxContainer
@onready var selected_unit_label: Label = $MarginContainer/Panel/VBoxContainer/Label

var player_done = false
var deployment_done = false
var unit_count = SaveState.unit_count

signal deployment_finished

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	begin_button.pressed.connect(_on_begin_pressed)
	begin_button.disabled = true
	game_over.modulate.a = 0
	unit_stats.hide_me()
	
	self.show()
	
	selected_unit_label.text = str(unit_count)
	
	#self.hide()
	#self.size = get_viewport().get_visible_rect().size

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.get_button_index() == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			var target_pos = camera.get_global_mouse_position()
			try_place_unit(target_pos)

func _on_begin_pressed():
	deployment_finished.emit()
	
	begin_button.queue_free()
	$MarginContainer.queue_free()

func try_place_unit(target_pos : Vector2):
	if(unit_count <= 0):
		return
	
	unit_manager.try_place_unit(0, target_pos)
	var result = false
	result = await unit_manager.unit_placed
	
	if result:
		unit_count -= 1
		selected_unit_label.text = str(unit_count)
		begin_button.disabled = false
	
	if unit_count <= 0:
		unit_stats.hide_me()

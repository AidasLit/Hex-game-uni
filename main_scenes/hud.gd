extends Control
class_name HUD

@onready var unit_manager: UnitManager = $"../unit-manager"
@onready var begin_button: Button = $"begin-button"
@onready var button_button: OptionButton = $"owner-choice"

@onready var deployable_units_container: HBoxContainer = $MarginContainer/ScrollContainer/HBoxContainer
const DEPLOYABLE_UNIT_TYPE = preload("res://main_scenes/deployable_unit_type.tscn")

var selected_id : int = -1

signal deployment_finished

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	begin_button.pressed.connect(_on_begin_pressed)
	begin_button.disabled = true
	self.hide()
	self.size = get_viewport().get_visible_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.get_button_index() == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			var target_pos = get_viewport().get_mouse_position()
			
			place_unit(target_pos)

func _on_begin_pressed():
	self.hide()
	
	deployment_finished.emit()
	
	## TODO temporary fix
	self.queue_free()

func show_deployable_units():
	self.show()
	
	var to_add : bool = true
	
	for unit_id in SaveState.units:
		for unit_button in deployable_units_container.get_children():
			if unit_button.id == unit_id:
				unit_button.amount += 1
				to_add = false
		
		if to_add:
			var temp = DEPLOYABLE_UNIT_TYPE.instantiate()
			temp.pressed.connect(_on_unit_selected.bind(temp))
			temp.icon = Globals.unit_types[unit_id].sprite
			temp.id = unit_id
			temp.amount += 1
			deployable_units_container.add_child(temp)
		
		to_add = true

func _on_unit_selected(unit_button):
	selected_id = unit_button.id

func place_unit(target_pos : Vector2):
	for unit_button in deployable_units_container.get_children():
		if unit_button.id == selected_id:
			unit_button.amount -= 1
			unit_manager.place_unit(selected_id, target_pos, button_button.selected)
			begin_button.disabled = false
			
			if unit_button.amount <= 0:
				selected_id = -1
				unit_button.queue_free()

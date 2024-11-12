extends Control
class_name HUD

@onready var unit_manager: UnitManager = $"../unit-manager"
@onready var begin_button: Button = $"begin-button"
@onready var owner_choice: OptionButton = $"owner-choice"

@onready var deployable_units_container: HBoxContainer = $MarginContainer/ScrollContainer/HBoxContainer
const DEPLOYABLE_UNIT_TYPE = preload("res://main_scenes/deployable_unit_type.tscn")

var selected_button = null

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
			
			try_place_unit(target_pos)

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
			temp.pressed.connect(_on_unit_selected.bind(temp), 1)
			temp.icon = Globals.unit_types[unit_id].sprite
			temp.id = unit_id
			temp.amount += 1
			deployable_units_container.add_child(temp)
		
		to_add = true

func _on_unit_selected(unit_button):
	selected_button = unit_button

func try_place_unit(target_pos : Vector2):
	if selected_button:
		unit_manager.try_place_unit(selected_button.id, target_pos, owner_choice.selected)
		var result = await unit_manager.unit_placed
		
		if result:
			selected_button.amount -= 1
			begin_button.disabled = false
		
		if selected_button.amount <= 0:
			selected_button.queue_free()
			selected_button = null

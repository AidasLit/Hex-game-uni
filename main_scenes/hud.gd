extends CanvasLayer
class_name HUD

@export var camera : Camera2D

@onready var unit_manager: UnitManager = $"../unit-manager"
@onready var begin_button: Button = $"begin-button"
@onready var current_owner: Label = $"current-owner"
@onready var game_over: Label = $"game-over"
@onready var unit_stats: StatsDisplay = $"PanelContainer/MarginContainer/unit-stats"
@onready var owner_choice: Globals.UnitOwner

@onready var deployable_units_container: HBoxContainer = $MarginContainer/ScrollContainer/HBoxContainer
const DEPLOYABLE_UNIT_TYPE = preload("res://main_scenes/deployable_unit_type.tscn")

var selected_button = null
var player_done = false
var deployment_done = false

signal deployment_finished

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	begin_button.pressed.connect(_on_begin_pressed)
	begin_button.disabled = true
	game_over.modulate.a = 0
	unit_stats.hide_me()
	
	#self.hide()
	#self.size = get_viewport().get_visible_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if deployment_done:
		return
	
	if event is InputEventMouseButton and event.get_button_index() == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			var target_pos = camera.get_global_mouse_position()
			try_place_unit(target_pos)

func _on_begin_pressed():
	if player_done:
		deployment_finished.emit()
		deployment_done = true
		
		begin_button.queue_free()
		$MarginContainer.queue_free()
	else:
		player_done = true
		begin_button.disabled = true
		show_deployable_units(Globals.UnitOwner.Enemy)

func setup_units():
	show_deployable_units(Globals.UnitOwner.Player)

func show_deployable_units(player : Globals.UnitOwner):
	self.show()
	
	for node in get_tree().get_nodes_in_group("deployment_button"):
		node.free()
	
	owner_choice = player
	
	set_team_label(player)
	
	var save_list = SaveState.unit_lists[player]
	
	var to_add : bool = true
	
	for unit_id in save_list:
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
			temp.add_to_group("deployment_button")
			deployable_units_container.add_child(temp)
		
		to_add = true

func _on_unit_selected(unit_button):
	var temp_stats = Globals.unit_types[unit_button.id]
	unit_stats.display_values(temp_stats.name,\
		temp_stats.max_hp, temp_stats.damage, temp_stats.slowness, temp_stats.movement_range)
	unit_stats.show_me()
	selected_button = unit_button

func try_place_unit(target_pos : Vector2):
	if selected_button:
		unit_manager.try_place_unit(selected_button.id, target_pos, owner_choice)
		var result = false
		result = await unit_manager.unit_placed
		
		if result:
			selected_button.amount -= 1
			begin_button.disabled = false
		
		if selected_button.amount <= 0:
			unit_stats.hide_me()
			selected_button.queue_free()
			selected_button = null

func set_team_label(player : Globals.UnitOwner):
	var label_stylebox = current_owner.get_theme_stylebox("normal")
	label_stylebox.bg_color = Globals.team_colors[player]
	match player:
		Globals.UnitOwner.Player:
			current_owner.text = "Player 1"
		Globals.UnitOwner.Enemy:
			current_owner.text = "Player 2"
		_:
			current_owner.text = "error"

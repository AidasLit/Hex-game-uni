extends Control

@export var start_button: Button
@export var quit_button: Button

# Called when the node enters the scene tree for the first time.
func _ready():
	start_button.pressed.connect(_on_start_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_start_button_pressed():
	SceneManager.change_scene("res://main_scenes/combat_scene.tscn")

func _on_quit_button_pressed():
	get_tree().quit()

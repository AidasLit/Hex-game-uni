extends Sprite2D

@export var health_component : HealthComponent
@onready var health_bar: ProgressBar = $SubViewport/HealthBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !health_component:
		push_warning(str(self) + ": health component node must be set")
	
	health_component.hp_changed.connect(hp_changed)
	health_component.zero_hp.connect(die)
	health_bar.max_value = health_component.max_hp


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func hp_changed(value : int):
	health_bar.value = value

func die():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "transparency", 1, 0.5)
	await tween.finished
	queue_free()

extends VBoxContainer
class_name StatsDisplay

func display_unit(unit : PlayableUnit):
	$slowness.hide()
	$"move-range".hide()
	$name.text = "Name: " + unit.unit_res.name
	$hp.text = "HP: " + str(unit.health_component.current_hp) + " / " + str(unit.health_component.max_hp)
	$damage.text = "Damage: " + str(unit.unit_res.damage)

func display_values(name : String, max_hp : int, damage : int, slowness : int, range : int):
	$slowness.show()
	$"move-range".show()
	$name.text = "Name: " + name
	$hp.text = "Max HP: " + str(max_hp)
	$damage.text = "Damage: " + str(damage)
	$slowness.text = "Act meter: " + str(slowness)
	$"move-range".text = "Movement range: " + str(range)

func hide_me():
	$"../..".hide();

func show_me():
	$"../..".show();

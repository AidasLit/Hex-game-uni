extends VBoxContainer
class_name StatsDisplay

func display_unit(unit : PlayableUnit):
	$slowness.hide()
	$"move-range".hide()
	$name.text = "Name: " + unit.my_name
	$hp.text = "HP: " + unit.health_component.text()
	$damage.text = "Damage: " + str(unit.damage)

func display_values(unit_name : String, max_hp : int, damage : int, slowness : int, movement_range : int):
	$slowness.show()
	$"move-range".show()
	$name.text = "Name: " + unit_name
	$hp.text = "Max HP: " + str(max_hp)
	$damage.text = "Damage: " + str(damage)
	$slowness.text = "Act meter: " + str(slowness)
	$"move-range".text = "Movement range: " + str(movement_range)

func display_planning(unit: PlayableUnit):
	$name.text = unit.agent.get_current_goal().get_title()
	#$name.text = str(unit.agent.get_current_plan().get_plan()[unit.agent.get_current_plan_step()].get_title())


func hide_me():
	$"../..".hide();

func show_me():
	$"../..".show();

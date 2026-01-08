extends GdPAIObjectData
class_name HealthSpaceData

var tilemap_position : Vector2i

# Override
func get_group_labels():
	# Make sure to add a group label for this class of data.
	return ["HealthSpaceData", "GdPAIObjectData"]


# Override
func get_provided_actions() -> Array[Action]:
	var enter_healing_action : EnterHealingAction = EnterHealingAction.new(
		get_parent()
	)
	return [enter_healing_action]


# Override
func copy_for_simulation() -> GdPAIObjectData:
	# Make sure to replace <GdPAIObjectData> with the subclass name, and to duplicate any new properties.
	var new_data: HealthSpaceData = HealthSpaceData.new()
	assign_uid_and_entity(new_data)
	new_data.tilemap_position = tilemap_position
	return new_data

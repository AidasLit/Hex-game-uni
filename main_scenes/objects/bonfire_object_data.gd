class_name BonfireObjectData
extends GdPAIObjectData

var tilemap_position : Vector2i

# Override
func get_group_labels():
	# Make sure to add a group label for this class of data.
	return ["BonfireObjectData", "GdPAIObjectData"]


# Override
func get_provided_actions() -> Array[Action]:
	var move_to_action: MoveToAction = MoveToAction.new(
		tilemap_position
	)
	var throw_wood_action : ThrowWoodAction = ThrowWoodAction.new(
		get_parent()
	)
	return [move_to_action, throw_wood_action]


# Override
func copy_for_simulation() -> GdPAIObjectData:
	# Make sure to replace <GdPAIObjectData> with the subclass name, and to duplicate any new properties.
	var new_data: BonfireObjectData = BonfireObjectData.new()
	assign_uid_and_entity(new_data)
	new_data.tilemap_position = tilemap_position
	return new_data

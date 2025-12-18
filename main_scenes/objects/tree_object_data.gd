class_name TreeObjectData
extends GdPAIObjectData

var tilemap_position : Vector2i
var play_loop : Node2D
var grid_system : GridNavigationSystem

# Override
func get_group_labels():
	# Make sure to add a group label for this class of data.
	return ["TreeObjectData", "GdPAIObjectData"]


# Override
func get_provided_actions() -> Array[Action]:
	#Overwrite the get_provided_actions function to serve any actions that become possible because
	#this object exists out in the world.
	#var shake_tree_action: CutTreeAction = CutTreeAction.new(
		#self,
	#)
	var move_to_action: MoveToAction = MoveToAction.new(
		grid_system,
		play_loop,
		tilemap_position
	)
	return [move_to_action]


# Override
func copy_for_simulation() -> GdPAIObjectData:
	# Make sure to replace <GdPAIObjectData> with the subclass name, and to duplicate any new properties.
	var new_data: TreeObjectData = TreeObjectData.new()
	assign_uid_and_entity(new_data)
	new_data.tilemap_position = tilemap_position
	return new_data

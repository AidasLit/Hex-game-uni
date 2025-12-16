class_name TreeObjectData
extends GdPAIObjectData



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
	#return [shake_tree_action]
	return []


# Override
func copy_for_simulation() -> GdPAIObjectData:
	# Make sure to replace <GdPAIObjectData> with the subclass name, and to duplicate any new properties.
	var new_data: TreeObjectData = TreeObjectData.new()
	assign_uid_and_entity(new_data)
	#new_data.is_on_cooldown = is_on_cooldown
	return new_data

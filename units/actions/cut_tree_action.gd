class_name CutTreeAction
extends Action

var grid_system : GridNavigationSystem
var play_loop : Node

# Override
func _init(_grid_system: GridNavigationSystem, _play_loop: Node):
	# If implementing _init(), make sure to call super() so a uid is created.
	super()
	
	assert(_grid_system, "grid stsrem not set")
	grid_system = _grid_system
	play_loop = _play_loop


# Override
func get_validity_checks() -> Array[Precondition]:
	var checks: Array[Precondition] = []
	checks.append(Precondition.agent_has_property("entity"))
	checks.append(Precondition.agent_has_property("tilemap_position"))
	checks.append(Precondition.agent_property_equal_to("is_active", true))
	checks.append(Precondition.world_state_has_object_data_of_group("TreeObjectData"))
	return checks


# Override
func get_action_cost(agent_blackboard: GdPAIBlackboard, world_state: GdPAIBlackboard) -> float:
	return 1


# Override
func get_preconditions() -> Array[Precondition]:
	#var conditions: Array[Precondition] = []
	#conditions.append(Precondition.agent_property_equal_to("is_active", true))
	#return conditions
	return []


# Override
func simulate_effect(agent_blackboard: GdPAIBlackboard, world_state: GdPAIBlackboard):
	var sim_position: Vector2i = agent_blackboard.get_property("tilemap_position")
	sim_position.x += 1
	agent_blackboard.set_property("tilemap_position", sim_position)


# Override
func reverse_simulate_effect(agent_blackboard: GdPAIBlackboard, world_state: GdPAIBlackboard):
	pass


# Override
func pre_perform_action(agent: GdPAIAgent) -> Action.Status:
	# Cache location data.
	var agent_position: Vector2i = agent.blackboard.get_property("tilemap_position")
	agent.blackboard.set_property(uid_property("tilemap_position"), agent_position)
	
	print("\nmoving from action: ", agent_position)
	
	var possible_targets = grid_system.get_navigable_neighbors(agent_position)
	if possible_targets.is_empty():
		Globals.action_done.emit()
		return Action.Status.FAILURE
	
	var target_location : Vector2i = possible_targets.pick_random()
	agent.blackboard.set_property(uid_property("target_location"), target_location)
	
	# Set up movement flags.
	agent.blackboard.set_property(uid_property("prior_position"), agent_position)
	return Action.Status.SUCCESS


# Override
func perform_action(agent: GdPAIAgent, delta: float) -> Action.Status:
	var target_location = agent.blackboard.get_property(uid_property("target_location"))
	
	play_loop.cut_tree(target_location)
	
	agent.blackboard.get_property("entity").is_active = false
	return Action.Status.SUCCESS


# Override
func post_perform_action(agent: GdPAIAgent) -> Action.Status:
	agent.blackboard.erase_property(uid_property("tilemap_position"))
	agent.blackboard.erase_property(uid_property("target_location"))
	agent.blackboard.erase_property(uid_property("prior_position"))

	return Action.Status.SUCCESS

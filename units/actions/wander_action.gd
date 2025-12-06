class_name WanderAction
extends Action

var grid_system : GridNavigationSystem
var unit_manager : UnitManager

# Override
func _init(_grid_system: GridNavigationSystem, _unit_manager: UnitManager):
	# If implementing _init(), make sure to call super() so a uid is created.
	super()
	
	assert(_grid_system, "grid stsrem not set")
	grid_system = _grid_system
	unit_manager = _unit_manager


# Override
func get_validity_checks() -> Array[Precondition]:
	var checks: Array[Precondition] = []
	checks.append(Precondition.agent_has_property("entity"))
	checks.append(Precondition.agent_has_property("tilemap_position"))
	return checks


# Override
func get_action_cost(agent_blackboard: GdPAIBlackboard, world_state: GdPAIBlackboard) -> float:
	return 1


# Override
func get_preconditions() -> Array[Precondition]:
	return []


# Override
func simulate_effect(agent_blackboard: GdPAIBlackboard, world_state: GdPAIBlackboard):
	pass


# Override
func reverse_simulate_effect(agent_blackboard: GdPAIBlackboard, world_state: GdPAIBlackboard):
	pass


# Override
func pre_perform_action(agent: GdPAIAgent) -> Action.Status:
	# Cache location data.
	var agent_position: Vector2i = agent.blackboard.get_property("tilemap_position")
	agent.blackboard.set_property(uid_property("tilemap_position"), agent_position)
	
	var possible_targets = grid_system.get_navigable_neighbors(agent_position)
	if possible_targets.is_empty():
		return Action.Status.FAILURE
	
	var target_location : Vector2i = possible_targets.pick_random()
	agent.blackboard.set_property(uid_property("target_location"), target_location)
	
	# Set up movement flags.
	agent.blackboard.set_property(uid_property("prior_position"), agent_position)
	return Action.Status.SUCCESS


# Override
func perform_action(agent: GdPAIAgent, delta: float) -> Action.Status:
	var target_location = agent.blackboard.get_property(uid_property("target_location"))
	unit_manager.move_unit(agent.blackboard.get_property("entity"), target_location)
	#await unit_manager.action_done
	return Action.Status.SUCCESS


# Override
func post_perform_action(agent: GdPAIAgent) -> Action.Status:
	agent.blackboard.erase_property(uid_property("tilemap_position"))
	agent.blackboard.erase_property(uid_property("target_location"))
	agent.blackboard.erase_property(uid_property("prior_position"))

	return Action.Status.SUCCESS

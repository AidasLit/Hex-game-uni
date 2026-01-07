class_name TakeWoodAction
extends Action

var wood : WoodObject

func _init(_wood : WoodObject):
	wood = _wood


# Override
func get_validity_checks() -> Array[Precondition]:
	var checks: Array[Precondition] = []
	
	checks.append(Precondition.agent_has_property("entity"))
	checks.append(Precondition.agent_has_property("tilemap_position"))
	checks.append(Precondition.check_is_object_valid(wood))
	
	return checks


# Override
func get_action_cost(
		_agent_blackboard: GdPAIBlackboard, 
		_world_state: GdPAIBlackboard
) -> float:
	return 1


# Override
func get_preconditions() -> Array[Precondition]:
	var standing_next_to: Precondition = Precondition.new()
	standing_next_to.eval_func = func(blackboard: GdPAIBlackboard, _world_state: GdPAIBlackboard):
		var blackboard_agent_position = blackboard.get_property("tilemap_position")
		
		var available_neighbors = Globals.grid_system.get_neighbors(wood.tilemap_position)
		
		return available_neighbors.has(blackboard_agent_position)
	
	var agent_not_holding_item = Precondition.agent_property_equal_to("holding_item", false)
	
	return [standing_next_to, agent_not_holding_item]


# Override
func simulate_effect(
		agent_blackboard: GdPAIBlackboard, 
		world_state: GdPAIBlackboard
):
	var wood_count = world_state.get_property("wood_count")
	world_state.set_property("wood_count", wood_count - 1)
	
	agent_blackboard.set_property("holding_item", true)


# Override
func reverse_simulate_effect(
		agent_blackboard: GdPAIBlackboard, 
		world_state: GdPAIBlackboard
):
	#var wood_count = world_state.get_property("wood_count")
	#world_state.set_property("wood_count", wood_count + 1)
	#
	#agent_blackboard.set_property("holding_item", false)
	pass


# Override
func pre_perform_action(agent: GdPAIAgent) -> Action.Status:
	agent.blackboard.set_property(uid_property("action_started"), false)
	
	return Action.Status.SUCCESS


# Override
func perform_action(
		agent: GdPAIAgent, 
		_delta: float
) -> Action.Status:
	if not agent.entity.is_active:
		return Action.Status.RUNNING
	
	var started_status: bool = agent.blackboard.get_property(uid_property("action_started"))
	
	if not started_status:
		agent.blackboard.set_property(uid_property("action_started"), true)
		
		agent.entity.take_wood(wood)
	
	return Action.Status.RUNNING if agent.entity.is_active else Action.Status.SUCCESS


# Override
func post_perform_action(agent: GdPAIAgent) -> Action.Status:
	agent.blackboard.erase_property(uid_property("action_started"))
	return Action.Status.SUCCESS

func get_title() -> String:
	return "Chop tree"

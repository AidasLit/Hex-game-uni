class_name WanderAction
extends Action

var wander_distance: int

# Override
func _init(to_wander_distance: int):
	# If implementing _init(), make sure to call super() so a uid is created.
	super()
	wander_distance = to_wander_distance


# Override
func get_validity_checks() -> Array[Precondition]:
	return []


# Override
func get_action_cost(agent_blackboard: GdPAIBlackboard, world_state: GdPAIBlackboard) -> float:
	return wander_distance


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
	return Action.Status.SUCCESS


# Override
func perform_action(agent: GdPAIAgent, delta: float) -> Action.Status:
	return Action.Status.SUCCESS


# Override
func post_perform_action(agent: GdPAIAgent) -> Action.Status:
	return Action.Status.SUCCESS

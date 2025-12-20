class_name ChopTreeAction
extends Action

var target : Vector2i
var tree : TreeObject

# Override
func _init(_target: Vector2i, _tree : TreeObject):
	# If implementing _init(), make sure to call super() so a uid is created.
	super()
	
	target = _target
	tree = _tree

# Override
func get_validity_checks() -> Array[Precondition]:
	var checks: Array[Precondition] = []
	checks.append(Precondition.agent_has_property("entity"))
	checks.append(Precondition.agent_has_property("tilemap_position"))
	checks.append(Precondition.agent_property_equal_to("is_active", true))
	checks.append(Precondition.check_is_object_valid(tree))
	
	var can_get_to_check: Precondition = Precondition.new()
	can_get_to_check.eval_func = func(blackboard: GdPAIBlackboard, world_state: GdPAIBlackboard):
		var entity: Node = blackboard.get_property("entity")
		var agent_position: Vector2i = entity.tilemap_position
		
		var path = Globals.grid_system.get_navigation_path(agent_position, target, true)
		
		#print("can get to to: ", not path.is_empty())
		return not path.is_empty()

	var standing_next_to: Precondition = Precondition.new()
	standing_next_to.eval_func = func(blackboard: GdPAIBlackboard, world_state: GdPAIBlackboard):
		var entity: Node = blackboard.get_property("entity")
		var agent_position: Vector2i = entity.tilemap_position
		
		var available_neighbors = Globals.grid_system.get_neighbors(agent_position)
		
		return available_neighbors.has(target)
	
	checks.append(can_get_to_check)
	checks.append(standing_next_to)
	
	return checks


# Override
func get_action_cost(agent_blackboard: GdPAIBlackboard, world_state: GdPAIBlackboard) -> float:
	return 1


# Override
func get_preconditions() -> Array[Precondition]:
	return []


# Override
func simulate_effect(agent_blackboard: GdPAIBlackboard, world_state: GdPAIBlackboard):
	var tree_count = world_state.get_property("tree_count")
	world_state.set_property("tree_count", tree_count - 1)


# Override
func reverse_simulate_effect(agent_blackboard: GdPAIBlackboard, world_state: GdPAIBlackboard):
	pass


# Override
func pre_perform_action(agent: GdPAIAgent) -> Action.Status:
	agent.blackboard.set_property(uid_property("target_position"), target)
	
	return Action.Status.SUCCESS


# Override
func perform_action(agent: GdPAIAgent, delta: float) -> Action.Status:
	var target_position = agent.blackboard.get_property(uid_property("target_position"))
	
	Globals.play_loop.cut_tree(target_position)
	
	agent.blackboard.get_property("entity").is_active = false
	return Action.Status.SUCCESS


# Override
func post_perform_action(agent: GdPAIAgent) -> Action.Status:
	agent.blackboard.erase_property(uid_property("target_position"))
	return Action.Status.SUCCESS

func get_title() -> String:
	return "Chop tree"

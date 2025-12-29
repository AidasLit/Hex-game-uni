class_name ChopTreeAction
extends Action

var tree : TreeObject

# Override
func _init(_tree : TreeObject):
	# If implementing _init(), make sure to call super() so a uid is created.
	super()
	
	tree = _tree

# Override
func get_validity_checks() -> Array[Precondition]:
	var checks: Array[Precondition] = []
	checks.append(Precondition.agent_has_property("entity"))
	checks.append(Precondition.agent_has_property("tilemap_position"))
	checks.append(Precondition.agent_property_equal_to("is_active", true))
	checks.append(Precondition.check_is_object_valid(tree))
	
	#var standing_next_to: Precondition = Precondition.new()
	#standing_next_to.eval_func = func(blackboard: GdPAIBlackboard, world_state: GdPAIBlackboard):
		#var agent : PlayableUnit = blackboard.get_property("entity")
		#
		#var available_neighbors = Globals.grid_system.get_neighbors(tree.tilemap_position)
		#
		#print("VALIDITY: ChopTree - tree pos: ", tree.tilemap_position, ", simulated pos: ", agent.tilemap_position)
		#
		#return available_neighbors.has(agent.tilemap_position)
	#
	#checks.append(standing_next_to)
	
	var validity_print: Precondition = Precondition.new()
	validity_print.eval_func = func(blackboard: GdPAIBlackboard, world_state: GdPAIBlackboard):
		print("\nVALIDITY: ChopAction - ", true)
		return true
	
	checks.append(validity_print)
	
	return checks


# Override
func get_action_cost(agent_blackboard: GdPAIBlackboard, world_state: GdPAIBlackboard) -> float:
	return 1


# Override
func get_preconditions() -> Array[Precondition]:
	var standing_next_to: Precondition = Precondition.new()
	standing_next_to.eval_func = func(blackboard: GdPAIBlackboard, world_state: GdPAIBlackboard):
		var blackboard_agent_position = blackboard.get_property("tilemap_position")
		
		var available_neighbors = Globals.grid_system.get_neighbors(tree.tilemap_position)
		
		print("PRECONDITION: ChopTree - tree pos: ", tree.tilemap_position, ", simulated pos: ", blackboard_agent_position)
		
		return available_neighbors.has(blackboard_agent_position)
	return [standing_next_to]


# Override
func simulate_effect(agent_blackboard: GdPAIBlackboard, world_state: GdPAIBlackboard):
	var tree_count = world_state.get_property("tree_count")
	world_state.set_property("tree_count", tree_count - 1)
	print("SIMULATION: ChopTree")


# Override
func reverse_simulate_effect(agent_blackboard: GdPAIBlackboard, world_state: GdPAIBlackboard):
	var tree_count = world_state.get_property("tree_count")
	world_state.set_property("tree_count", tree_count + 1)
	print("REVERSE SIM: ChopTree")


# Override
func pre_perform_action(agent: GdPAIAgent) -> Action.Status:
	agent.blackboard.set_property(uid_property("target_position"), tree.tilemap_position)
	
	print("\nACTION: ChopTree")
	
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

event_inherited();
part_system_depth(partSystem, getTrueDepth(bbox_bottom, 0.5));

if !combatant.states.inCombat {
	followingObj = global.focusObject;
	if combatant.states.controlState != controlStates.CONTROLLED combatant.states.controlState = controlStates.FOLLOWING;
};

//if combatant.states.controlState != controlStates.CONTROLLED && input_check("accept") {
//	var _test_stats = new CombatStats()
//	_test_stats.hp = -5;
//	spawn_skill_collider(id, [new scene_dialogue(global.focusObject, "THIS WORKED")], _test_stats, skillTarget.ENEMIES, 500, 500)
//};
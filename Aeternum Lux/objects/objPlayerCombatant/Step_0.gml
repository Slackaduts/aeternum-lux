event_inherited();
part_system_depth(partSystem, getTrueDepth(bbox_bottom, 0.5));

if !combatant.states.inCombat {
	followingObj = global.focusObject;
	if combatant.states.controlState != controlStates.CONTROLLED combatant.states.controlState = controlStates.FOLLOWING;
};
/// @desc Upd Focus, switch if needed

keyRotate = input_check("rotate");

if keyRotate && canRotate {
	canRotate = false;
	global.focusInstance.combatant.states.controlState = controlStates.FOLLOWING;
	focusIndex += 1;
	
	if focusIndex >= array_length(global.partyObjects) focusIndex = 0;

	while global.partyObjects[focusIndex] == noone {
		focusIndex += 1;
		if focusIndex >= array_length(global.partyObjects) focusIndex = 0;
	};
	alarm[1] = 20;
};


global.focusObject = global.partyObjects[focusIndex];
if instance_exists(global.focusObject) {
	global.focusInstance = instance_find(global.focusObject, 0);
	global.focusInstance.combatant.states.controlState = controlStates.CONTROLLED;
};
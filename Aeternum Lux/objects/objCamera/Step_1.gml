/// @desc Upd Focus, switch if needed

keyRotate = input_check("rotate");


if keyRotate && canRotate && instance_exists(global.focusObject) {
	var _inst = instance_find(global.focusObject, 0);
	canRotate = false;
	_inst.combatant.states.controlState = controlStates.FOLLOWING;
	focusIndex += 1;
	
	if focusIndex >= array_length(global.partyObjects) focusIndex = 0;

	while global.partyObjects[focusIndex] == noone { // NOTE: THIS IS SUS AS FUCK, WHY DID WE DO THIS?
		focusIndex += 1;
		if focusIndex >= array_length(global.partyObjects) focusIndex = 0;
	};
	alarm[1] = 20;
};


global.focusObject = global.partyObjects[focusIndex];
if instance_exists(global.focusObject) {
	var _inst = instance_find(global.focusObject, 0);
	_inst.combatant.states.controlState = controlStates.CONTROLLED;
};
/// @desc Upd Focus, switch if needed

global.partyInstances = [];
var localPartyObjects = global.partyObjects;
for (var currObj = 0; currObj < array_length(localPartyObjects); currObj++) {
	var currInst = instance_find(localPartyObjects[currObj], 0);
	array_push(global.partyInstances, currInst);
	
};

keyRotate = input_check("rotate");

if keyRotate && canRotate {
	canRotate = false;
	global.focusInstance.combatant.states.controlState = controlStates.FOLLOWING;
	focusIndex += 1;
	
	if focusIndex >= array_length(global.partyInstances) focusIndex = 0;

	while global.partyInstances[focusIndex] == noone {
		focusIndex += 1;
		if focusIndex >= array_length(global.partyInstances) focusIndex = 0;
	};
	alarm[1] = 20;
};

global.focusObject = global.partyObjects[focusIndex];
global.focusInstance = global.partyInstances[focusIndex];
global.focusInstance.combatant.states.controlState = controlStates.CONTROLLED;
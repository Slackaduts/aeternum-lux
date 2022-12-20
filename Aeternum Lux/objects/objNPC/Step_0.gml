/// @desc Run NPC scene
event_inherited();

if instance_exists(global.focusObject) {
	var _inst = instance_find(global.focusObject, 0);
	var _activated = (input_check_pressed("accept")); // make this a range check + keyboard input check
	if (_activated && distance_to_object(_inst) < npcActivationRange) || npcScene.scenePlaying npcScene.run();
}

//npcScene.run();
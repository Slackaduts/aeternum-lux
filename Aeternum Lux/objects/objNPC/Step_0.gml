/// @desc Run NPC scene
event_inherited();

if instance_exists(global.focusObject) {
	var _inst = instance_find(global.focusObject, 0);
	if (input_check_pressed("accept") && distance_to_object(_inst) < npcActivationRange) || npcScene.scenePlaying npcScene.run();
}

//npcScene.run();
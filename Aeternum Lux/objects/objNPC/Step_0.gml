/// @desc Proximity Dialogue
event_inherited();

if global.focusInstance != undefined {
	var _dist = point_distance(x, y, global.focusInstance.x, global.focusInstance.y);
	var _nearestNPC = instance_nearest(global.focusInstance.x, global.focusInstance.y, objNPC);
	
	if _dist <= activationRange && _nearestNPC == id {
		objFocusIndicator.focusObj = id;
		objFocusIndicator.focusState = focusStates.OBJECT;
		if !sceneManager.cutsceneOver objFocusIndicator.indicatorState = indicatorStates.ALERT;
		else objFocusIndicator.indicatorState = indicatorStates.TALK; 
		sceneManager.npc_activate_scene();
		
		
	} else if _nearestNPC == id {
		objFocusIndicator.focusState = focusStates.PLAYER;
		objFocusIndicator.indicatorState = indicatorStates.IDLE;
		if sceneManager.cutscenePlaying sceneManager.next_scene(array_length(sceneManager.scenes) - 1);
	} else if sceneManager.cutscenePlaying sceneManager.next_scene(array_length(sceneManager.scenes) - 1);
	
	
};
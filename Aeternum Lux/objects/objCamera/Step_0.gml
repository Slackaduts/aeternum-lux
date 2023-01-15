/// @desc Update audio listener position
if global.focusObject != undefined && instance_exists(global.focusObject) {
	var _inst = instance_find(global.focusObject, 0);
	audio_listener_position(_inst.x, _inst.y, 0);
};
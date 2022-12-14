/// @desc Sync XY and adjust Alpha

if instance_exists(global.focusObject) {
	var _inst = instance_find(global.focusObject, 0);
	x = _inst.x;
	y = (_inst.y - _inst.sprite_yoffset) + 2;
};
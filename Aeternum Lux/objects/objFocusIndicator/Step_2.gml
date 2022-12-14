/// @desc Sync Sprite

if instance_exists(global.focusObject) {
	var _inst = instance_find(global.focusObject, 0);
	x += _inst.velocity.x;
	y += _inst.velocity.y;
};

image_index = indicatorState;
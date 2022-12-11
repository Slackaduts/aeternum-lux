/// @desc Sync XY and adjust Alpha

if global.focusInstance != undefined {
	x = global.focusInstance.x;
	y = (global.focusInstance.y - global.focusInstance.sprite_yoffset) + 2;
};
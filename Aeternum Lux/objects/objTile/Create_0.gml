/// @desc Check if this tile is empty, destroy self if true
event_inherited();
if collision_rectangle(x, y, x + tileWidth, y + tileHeight, id, true, false) == noone {
	instance_destroy();
};
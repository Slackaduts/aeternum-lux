/// @desc Sync light positions
event_inherited();
for (var currLight = 0; currLight < array_length(lights); currLight++) {
	lights[currLight].x = x;
	lights[currLight].y = y;
};
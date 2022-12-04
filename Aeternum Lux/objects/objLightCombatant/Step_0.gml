/// @desc Sync light positions
event_inherited();
for (var currLight = 0; currLight < array_length(lights); currLight++) {
	lights[currLight].x = x + lightXOffset;
	lights[currLight].y = y + lightYOffset;
};

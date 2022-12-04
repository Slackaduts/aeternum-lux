/// @desc remove lights from world
event_inherited();
for (var currLight = 0; currLight < array_length(lights); currLight++) {
	lights[currLight].Destroy();
};

lights = [];
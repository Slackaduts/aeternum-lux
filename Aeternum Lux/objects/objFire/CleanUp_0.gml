/// @desc Destroy Lights
event_inherited();
for (var currLight = 0; currLight < array_length(lights); currLight++) {
	lights[currLight].Destroy();
};

lights = [];
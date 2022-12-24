/// @desc Handle main menu and pausing

var _pressed = input_check_pressed("pause");

if _pressed {
	if paused {
		instance_destroy(yui, true);
		yui = undefined;
		
	} else pause();
};

/// @desc Handle main menu and pausing

var _pressed = input_check_pressed("pause");

if _pressed {
	if paused unpause();
	else {
		pause();
		yui = create_yui_obj("YUI/Screens/main_menu.yui", id);
	};
};


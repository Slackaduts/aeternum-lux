function get_current_time() {
	return current_time;
};


function get_room_speed() {
	return room_speed;
};


/**
 * Creates a string for showing amounts in a GUI. Workaround for incomplete string concat implementation in YUI.
 * @param {real} _amount Number to show as an amount
 * @returns {string} The gui-ready amount string
 */
function gui_amount_view(_amount) {
	return string_concat("x", string(_amount))
};


function create_yui_obj(_yui_file, _data_context) {
	return instance_create_depth(0, 0, 0, yui_document, {yui_file: _yui_file, data_context: _data_context});
};
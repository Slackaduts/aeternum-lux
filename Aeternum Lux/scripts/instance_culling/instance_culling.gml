
function cull_instances(_buffer = 250) {
	var _x1 = (camera_get_view_x(view_camera[0]) - (objCamera.viewWidth / 2)) - _buffer;
	var _x2 = (camera_get_view_x(view_camera[0]) + (objCamera.viewWidth / 2)) + _buffer;
	var _y1 = (camera_get_view_y(view_camera[0]) - (objCamera.viewHeight / 2)) - _buffer;
	var _y2 = (camera_get_view_y(view_camera[0]) + (objCamera.viewHeight / 2)) + _buffer;

	for (var _index = 0; 0 < array_length(instance_id); _index++) {
		var _inst = instance_id[_index];
		if _inst.id != other.id && variable_instance_exists(_inst, "canDeactivate") && _inst.canDeactivate {
			if !point_in_rectangle(_inst.x, _inst.y, _x1, _x2, _y1, _y2) instance_deactivate_object(_inst);
			else instance_activate_object(_inst);
		};
	};
};


/// @desc Sync camera position
camera_set_view_size(view_camera[0], viewWidth / zoomFactor, viewHeight / zoomFactor);

var _currCamX = camera_get_view_x(view_camera[0]);
var _currCamY = camera_get_view_y(view_camera[0]);

if instance_exists(global.focusObject) {
	var _inst = instance_find(global.focusObject, 0);
	camX = clamp(_inst.x - ((viewWidth / zoomFactor) / 2), 0, room_width - (viewWidth / zoomFactor));
	camY = clamp(_inst.y - ((viewHeight / zoomFactor) / 2), 0, room_height - (viewHeight / zoomFactor));
	
	var _newCamX = round(lerp(_currCamX, camX, global.cameraSpeed));
	var _newCamY = round(lerp(_currCamY, camY, global.cameraSpeed));

	camera_set_view_pos(view_camera[0], _newCamX, _newCamY);
	_currCamX = _newCamX;
	_currCamY = _newCamY;
};

if _currCamX != pastCamX || _currCamY != pastCamY isMoving = true;
else isMoving = false;

pastCamX = _currCamX;
pastCamY = _currCamY;


//instance_deactivate_region(camX - 256, camY  - 256, camX + viewWidth + 256, camY + viewHeight + 256, false, true);
//instance_activate_region(camX - 256, camY - 256, camX + viewWidth + 256, camY + viewHeight + 256, true);
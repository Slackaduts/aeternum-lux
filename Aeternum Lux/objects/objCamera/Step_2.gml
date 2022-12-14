/// @desc Sync camera position
camera_set_view_size(view_camera[0], viewWidth, viewHeight);

if instance_exists(global.focusObject) {
	var _inst = instance_find(global.focusObject, 0);
	camX = clamp(_inst.x - (viewWidth / 2), 0, room_width - viewWidth);
	camY = clamp(_inst.y - (viewHeight / 2), 0, room_height - viewHeight);

	var _currCamX = camera_get_view_x(view_camera[0]);
	var _currCamY = camera_get_view_y(view_camera[0]);
	
	camera_set_view_pos(view_camera[0], lerp(_currCamX, camX, global.cameraSpeed), lerp(_currCamY, camY, global.cameraSpeed));
};

//instance_deactivate_region(camX - 256, camY  - 256, camX + viewWidth + 256, camY + viewHeight + 256, false, true);
//instance_activate_region(camX - 256, camY - 256, camX + viewWidth + 256, camY + viewHeight + 256, true);
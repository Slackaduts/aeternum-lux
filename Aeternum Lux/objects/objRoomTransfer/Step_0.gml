/// @desc Check player distance, init room transfer


if global.focusInstance != undefined {
	if distance_to_object(global.focusInstance) <= activationRange {
		room_transfer(targetX, targetY, roomName);
		//instance_destroy(id, true);
	};
};
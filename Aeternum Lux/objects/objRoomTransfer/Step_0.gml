/// @desc Check player distance, init room transfer


if instance_exists(global.focusObject) {
	if distance_to_object(instance_find(global.focusObject, 0)) <= activationRange {
		room_transfer(targetX, targetY, roomName);
		//instance_destroy(id, true);
	};
};
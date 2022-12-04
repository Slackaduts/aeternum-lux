/// @desc Z Sort and Animate



//Set depth
depth = getTrueDepth(bbox_bottom);

// Update Sprite Image Index
if velocity.get_magnitude() || proxyVelocity {
	//direction = inputDirection;
	animate_sprite(walkIndexes, inputDirection);

} else animate_sprite(idleIndexes, inputDirection);

//Sync position vector with actual position
position.x = x;
position.y = y;
/// @desc Z Sort and Animate



//Set depth
depth = getTrueDepth(bbox_bottom);

// Update Sprite Image Index
if animState == animationStates.IDLE || animState == animationStates.WALK {
	if velocity.get_magnitude() || proxyVelocity animState = animationStates.WALK;
	else animState = animationStates.IDLE;
};

animate_sprite(LPC_ANIMATION_DATA, inputDirection, animState);


//Sync position vector with actual position
position.x = x;
position.y = y;
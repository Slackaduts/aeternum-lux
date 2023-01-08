/// @desc Z Sort and Animate

//Set depth
depth = getTrueDepth(bbox_bottom);

// Only change animation state to idle if we were walking, or walking if idle
if animState == animationStates.IDLE || animState == animationStates.WALK {
	if velocity.get_magnitude() || proxyVelocity animState = animationStates.WALK;
	else animState = animationStates.IDLE;
};

// Update the image index of the sprite
animate_sprite(animData, inputDirection, animState);


//Sync position vector with actual position
position.x = x;
position.y = y;
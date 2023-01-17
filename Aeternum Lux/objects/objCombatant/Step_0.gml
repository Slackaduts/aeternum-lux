/// @desc Movement
event_inherited();


if combatant.states.controlState == controlStates.CONTROLLED {
// Get Movement Inputs
keyLeft = input_check("left");
keyRight = input_check("right");
keyUp = input_check("up");
keyDown = input_check("down");

// Get Skill Inputs
keyJump = input_check("jump");
keySprint = input_check("sprint");
keySkill1 = input_check("skill1");
keySkill2 = input_check("skill2");
keySkill3 = input_check("skill3");
keySkill4 = input_check("skill4");
keySkill5 = input_check("skill5");
keySkill6 = input_check("skill6");
} else {
keyLeft = 0;
keyRight = 0;
keyUp = 0;
keyDown = 0;

keyJump = 0;
keySprint = 0;
keySkill1 = 0;
keySkill2 = 0;
keySkill3 = 0;
keySkill4 = 0;
keySkill5 = 0;
keySkill6 = 0;
};

// Calculate direction & magnitude based on movement inputs
var localDirection = point_direction(0, 0, keyRight - keyLeft, keyDown - keyUp);

inputMagnitude = (keyRight - keyLeft != 0) || (keyDown - keyUp != 0);
if (inputMagnitude != 0) inputDirection = localDirection;

velocity.x = 0;
velocity.y = 0;
proxyVelocity = 0;

tweenManager.run();

// If we are being controlled by inputs or following, handle movement
if followingObj != undefined && instance_number(followingObj) > 0 {
switch combatant.states.controlState {
	case controlStates.IDLE:
		apply_force(seperation_force());
	break;
	case controlStates.STATIC:
	break;	
	case controlStates.LAST:
	break;
	
	case controlStates.CONTROLLED:
		tweenManager.clear();
		if inputMagnitude {
		var _inputForce = new vector_lengthdir(inputMagnitude * spdWalk, inputDirection);
		apply_force(_inputForce);
		};
	break;
	
	case controlStates.FOLLOWING:
		tweenManager.clear();
		if followingObj != id && followingObj != undefined {
			apply_force(pathfind_force(followingObj.x, followingObj.y));
			//apply_force(arrive_force(followingObj.position, followingObj.velocity, followingObj.x, followingObj.y, maximumCrowding * 3, maximumCrowding));
		};
		apply_force(seperation_force());
	break;
	
	case controlStates.WANDERING:
		//above is perlin noise wandering, below is reynold's wandering
		//show_debug_message(x + (perlin_noise(wanderPerlinX) * 144));
		
		//if array_length(tweenManager.tweens) == 0 {
		//	var _wanderBehavior = irandom_range(0, 4);
			
		//	if _wanderBehavior >= 3 {
		//		wanderPerlinX += wanderPerlinIncrement;
		//		tweenManager.add(new Tween(irandom_range(2, 4) * room_speed, [x, y], [x + (perlin_noise(wanderPerlinX) * 144), y + (perlin_noise(wanderPerlinX) * 144)], TWEEN_MOVEMENT, "Linear"));
		//	} else {
		//		tweenManager.add(new Tween(irandom_range(2, 4) * room_speed, [x, y], [x, y], TWEEN_MOVEMENT, "Linear"));	
		//	};
			
		//};
		apply_force(seperation_force());
	break;	
};
};

combatant.update();
scenePool.run();

if global.movementStatus {
	//Update steering/velocity vectors
	velocity.add(steeringForce);
	velocity.limit_magnitude(spdWalk);
	position.add(velocity);
	steeringForce.set(0, 0);

	//Run Movement
	movement.xSpdYSpd(velocity.x, velocity.y);
};
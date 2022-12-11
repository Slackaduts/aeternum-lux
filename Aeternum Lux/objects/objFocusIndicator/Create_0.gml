/// @desc Set Depth
depth = 0;
indicatorColor = c_white;

enum indicatorStates {
	IDLE,
	ALERT,
	TALK,
	INVISIBLE,
	LAST
};

indicatorState = indicatorStates.IDLE;
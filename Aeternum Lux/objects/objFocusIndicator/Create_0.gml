/// @desc Set Depth
depth = 0;
indicatorColor = c_white;
focusObj = global.focusInstance;

enum focusStates {
	IDLE,
	PLAYER,
	OBJECT,
	LAST
};

enum indicatorStates {
	IDLE,
	ALERT,
	TALK,
	INVISIBLE,
	LAST
};

focusState = focusStates.PLAYER;
indicatorState = indicatorStates.IDLE;
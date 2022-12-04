/// @desc Sync XY and adjust Alpha

switch focusState {
	case focusStates.IDLE:
	break;

	case focusStates.PLAYER:
		indicatorState = indicatorStates.IDLE;
		focusObj = global.focusInstance;
		if focusObj != undefined {
			x = focusObj.x;
			y = (focusObj.y - focusObj.sprite_yoffset) + 2;
		};
	break;

	case focusStates.OBJECT:
		if focusObj != undefined {
			x = focusObj.x;
			y = (focusObj.y - focusObj.sprite_yoffset) + 2;
		};
	break;
};
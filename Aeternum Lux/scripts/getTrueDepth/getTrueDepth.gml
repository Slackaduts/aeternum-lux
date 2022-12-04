/// @desc Returns the true depth of the y edge.
function getTrueDepth(_yEdge, _depthOffset = 0){
	return clamp(global.maxObjectDepth - (abs(_yEdge / room_height) * (global.maxObjectDepth - global.minObjectDepth)) + _depthOffset, global.minObjectDepth, global.maxObjectDepth);
};
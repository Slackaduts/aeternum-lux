function TWEEN_X(_value) { x = _value; };

function TWEEN_Y(_value) { y = _value; };

function TWEEN_XY(_value) {
	proxyVelocity = 1;
	inputDirection = point_direction(x, y, _value[0], _value[1]);
	x = _value[0];
	y = _value[1];
	
};

function TWEEN_ANGLE(_value) { image_angle = _value; };

function TWEEN_SIZE(_value) { image_xscale = _value; image_yscale = _value; };

function TWEEN_ALPHA(_value) { image_alpha = _value; };
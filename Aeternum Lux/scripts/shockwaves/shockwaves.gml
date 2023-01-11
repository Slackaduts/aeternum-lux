/// @desc Creates a PPFX shockwave.
/// @param {any*} _x X position of the shockwave
/// @param {any*} _y Y position of the shockwave
/// @param {real} [_spriteIndex]=0 Sprite index of the shockwave, default 0
/// @param {real} [_scale]=1 Scale of the shockwave, default 1
/// @param {real} [_speed]=0.01 Speed of the shockwave, default 0.01
/// @param {asset.gmanimcurve} [_curve]=__ac_ppf_shockwave Curve the shockwave uses
/// @param {asset.gmobject} [_obj]=__obj_ppf_shockwave Object the shockwave uses
/// @param {real} [_callbackIndex]=0 Index to go to upon completion, influences branching scene logic
function scene_create_shockwave(_x, _y, _spriteIndex = 0, _scale = 1, _speed = 0.01, _curve = __ac_ppf_shockwave, _obj = __obj_ppf_shockwave, _callbackIndex = 0): scene_callback(undefined, _callbackIndex) constructor {
	inst = undefined;
	x = _x;
	y = _y;
	spriteIndex = _spriteIndex;
	scale = _scale;
	speed = _speed;
	curve = _curve;
	obj = _obj;
	inst = undefined;
	
	/**
	 * Creates the shockwave.
	 */
	static initialize = function() {
		inst = shockwave_instance_create(x, y, "Instances", spriteIndex, scale, speed, obj);
	}
	
	/**
	 * Advances when the shockwave is finished.
	 */
	static run = function() {
		if inst == undefined finish();
	};
};
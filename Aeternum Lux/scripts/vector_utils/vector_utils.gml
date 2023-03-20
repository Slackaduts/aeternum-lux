function vector(_x, _y) constructor {
	x = _x;
	y = _y;
	
	static set = function(_x, _y) {
		x = _x;
		y = _y;	
	};

	static add = function(_vector) {
		x += _vector.x;
		y += _vector.y;
	};

	static subtract = function(_vector) {
		x -= _vector.x;
		y -= _vector.y;
	};
	
	static negate = function() {
		x = -x;
		y = -y;
	};

	static multiply = function(_scalar) {
		x *= _scalar;
		y *= _scalar;
	};

	static divide = function(_scalar) {
		x /= _scalar;
		y /= _scalar;
	};
	
	static get_magnitude = function() {
		return sqrt((x * x) + (y * y));
	};
	
	static get_direction = function() {
		return point_direction(0, 0, x, y);
	};
	
	static normalize = function() {
		if ((x != 0) || (y != 0)) {
			var _factor = 1 / get_magnitude();
			x *= _factor;
			y *= _factor;
		};
	};
	
	static set_magnitude = function(_scalar) {
		normalize();
		multiply(_scalar);		
	};
	
	static limit_magnitude = function(_limit) {
		if (get_magnitude() > _limit) set_magnitude(_limit);
	};
	
	static copy = function(_vector) {
		x = _vector.x;
		y = _vector.y;
	};
};


function vector_random(_length) : vector() constructor {
	var _dir = random(360);
	if is_undefined(_length) {
		x = lengthdir_x(_length, _dir);
		y = lengthdir_y(_length, _dir);
	};
};

function vector_lengthdir(_length, _dir) : vector() constructor {
	x = lengthdir_x(_length, _dir);
	y = lengthdir_y(_length, _dir);
};

function vector_copy(_vector) {
	return new vector(_vector.x, _vector.y);	
};

function vector_subtract(_vector_a, _vector_b) {
	return new vector((_vector_a.x - _vector_b.x), (_vector_a.y - _vector_b.y));	
};

function vector_add(_vector_a, _vector_b) {
	return new vector((_vector_a.x + _vector_b.x), (_vector_a.y + _vector_b.y));	
};

function apply_force(_force, _weight = 1) {
	_force.multiply(_weight);
	steeringForce.add(_force);
};

function seek_force(_x, _y) {
	var _vec = new vector(_x, _y);
	_vec.subtract(position);
	_vec.set_magnitude(spdWalk);
	_vec.subtract(velocity);
	_vec.limit_magnitude(maxForce);
	return _vec;
};

function flee_force(_x, _y) {
	var _vec = new vector(_x, _y);
	_vec.subtract(position);
	_vec.set_magnitude(spdWalk);
	_vec.negate();
	_vec.subtract(velocity);
	_vec.limit_magnitude(maxForce);
	return _vec;
};

function pursue_force(_inst) {
	var _vec = vector_copy(_inst.velocity);
	_vec.multiply(10);
	_vec.add(_inst.position);
	return seek_force(_vec.x, _vec.y);
};

function evade_force(_inst) {
	var _vec = vector_copy(_inst.velocity);
	_vec.multiply(10);
	_vec.add(_inst.position);
	return flee_force(_vec.x, _vec.y);
};


function arrive_custom_force(_force, _dist, _slowingRadius, _stopRadius, _maxForce = 5, _cutoff = 0.15) {
	//	var _vec = new vector(_x, _y);
	//_vec.subtract(_position);
	var _vec = vector_copy(_force);
	if _dist > _slowingRadius {
		_vec.set_magnitude(spdWalk);

	} else if _dist > _stopRadius {
		_vec.set_magnitude(spdWalk * (1 - clamp(_stopRadius / _dist, 0, 1)));
		
	} else _vec.set_magnitude(0);
	
	if _vec.get_magnitude() > _cutoff * spdWalk {
		_vec.subtract(velocity);
		_vec.limit_magnitude(maxForce);
	} else _vec.set_magnitude(0);

	return _vec;	
};


function arrive_force(_position, _velocity, _x, _y, _slowingRadius, _stopRadius, _maxForce = 5, _cutoff = 0.15) {
	var _vec = new vector(_x, _y);
	_vec.subtract(_position);
	var _dist = _vec.get_magnitude();
	if _dist > _slowingRadius {
		_vec.set_magnitude(spdWalk);

	} else if _dist > _stopRadius {
		_vec.set_magnitude(spdWalk * (1 - clamp(_stopRadius / _dist, 0, 1)));
		
	} else _vec.set_magnitude(0);
	
	if _vec.get_magnitude() > _cutoff * spdWalk {
		_vec.subtract(_velocity);
		_vec.limit_magnitude(maxForce);
	} else _vec.set_magnitude(0);

	return _vec;
};

function pathfind_force(_x, _y, _spd = spdWalk) {
	pathfindToXY(followingObj.x, followingObj.y);
	var _pathfindForce = new vector_lengthdir(_spd, inputDirection);
	var _dist = point_distance(x, y, followingObj.x, followingObj.y);
	return arrive_custom_force(_pathfindForce, _dist, maximumCrowding * 3, maximumCrowding);
};

function wander_force() {
	var _vec = vector_copy(velocity);
	_vec.set_magnitude(wanderDistance);
	_vec.add(new vector_lengthdir(wanderPower, image_angle + wanderAngle));
	_vec.limit_magnitude(maxForce);
	wanderAngle += random_range(-wanderChange, wanderChange);
	return _vec;
};

function align_force(_obj) {
	var _vec, _count;
	_vec = new vector(0, 0);
	_count = 0;
	
	with (_obj) {
		if (id == other.id) continue;
		_vec.add(velocity);
		_count += 1;		
	};
	
	if _count > 0 {
		_vec.set_magnitude(maxForce);
	};
	
	return _vec;
};

function cohesion_force(_obj) {
	var _vec, _count;
	_vec = new vector(0, 0);
	_count = 0;
	
	with (_obj) {
		if (id == other.id) continue;
		_vec.add(velocity);
		_count += 1;		
	};
	
	if _count > 0 {
		_vec.divide(_count);
		_vec = seek_force(_vec.x, _vec.y);
	};
	
	return _vec;
};


function seperation_force(_obj = objCombatant, _seperationDist = 48) {
	var _pastX = x;
	var _pastY = y;
	
	x = -1000000;
	y = -1000000;
	
	var _closestCombatant = instance_nearest(_pastX, _pastY, _obj)
	x = _pastX;
	y = _pastY;
	
	if _closestCombatant != undefined {
		var _dist = point_distance(x, y, _closestCombatant.x, _closestCombatant.y)
		if _dist < _seperationDist {
			var _dir = point_direction(_closestCombatant.x, _closestCombatant.y, x, y);
			var _repelForce = new vector_lengthdir(spdWalk, _dir);
			_repelForce.limit_magnitude(maxForce / 2);
			return _repelForce;
		};
	
	}; 
	
	return new vector(0, 0);

};



/**
 * Rotates a 2D positional vector about another by a specified number of degrees.
 * @param {any*} _vecOrigin Origin point of the rotation
 * @param {any*} _vecPoint Point to be rotated
 * @param {real} _theta Number of degrees to rotate by
 * @returns {struct.vector} Vector
 */
function rotate_point_vector(_vecOrigin, _vecPoint, _theta) {
	var _radians = degtorad(_theta);
	var _cos = cos(_radians);
	var _sin = sin(_radians);
	var _yDiff = _vecPoint.y - _vecOrigin.y;
	var _xDiff = _vecPoint.x - _vecOrigin.x;
	return new vector(_cos * _xDiff - _sin * _yDiff + _vecOrigin.x, _sin * _xDiff + _cos * _yDiff + _vecOrigin.y);
};


//function crowd_force(_obj, _seperationDist = 64)
enum colliderShapes {
	SQUARE,
	ELLIPSE,
	LAST	
};


function create_skill_collider(_hitboxData = {}, _infront = true, _addDist = 0, _theta = 0) {
	var _x = _hitboxData.caster.x;
	var _y = _hitboxData.caster.y;
	
	if _infront {
		_x -= _hitboxData.hitboxWidth * dsin(_hitboxData.caster.inputDirection);
		_y -= _hitboxData.hitboxHeight * dcos(_hitboxData.caster.inputDirection);
	};

	if _addDist > 0 {
		var _dist = point_distance(_hitboxData.caster.x, _hitboxData.caster.y, _x, _y);
		var _n = (_dist / _addDist) / _dist;
		_x = ((_x - _hitboxData.caster.x) * _n) + _hitboxData.caster.x;
		_y = ((_y - _hitboxData.caster.y) * _n) + _hitboxData.caster.y;
	};
	
	if _theta > 0 {
		var _vecOrigin = new vector(_hitboxData.caster.x, _hitboxData.caster.y);
		var _vecPoint = new vector(_x, _y);
		var _vecRotated = rotate_point_vector(_vecOrigin, _vecPoint, _theta);
		_x = _vecRotated.x;
		_y = _vecRotated.y;
	};

	return instance_create_depth(_x, _y, 0, objSkillHitbox, _hitboxData);
};



function CombatSkill(_name, _desc, _scene, _triggerStats, _hitboxData = {}, _cooldown = 1, _costStats = new CombatStats(), _target = skillTarget.ENEMIES) constructor {
	name = _name;
	desc = _desc;

	scene = _scene;

	stats = _triggerStats;
	cost = _costStats;

	cooldown = _cooldown;
	coolingDown = false;

	target = _target;

	hitbox = undefined;
	hitboxData = _hitboxData;
	hitboxData.sceneOnHit = _sceneOnHit;
	hitboxData.stats = stats;
	hitboxData.target = target;
	
	static is_castable = function(_caster = other) {
		return (!coolingDown && _caster.combatant.liveStats.hasStats(cost));
	};
	
	static trigger = function(_caster = other) {
		hitboxData.caster = _caster;
		hitbox = create_skill_collider(hitboxData);
	};
	
	static cast = function(_caster = other, _override = true) {
		if is_castable(_caster) || _override {
			_caster.combatant.liveStats.revokeStats(stats);
			var _scene = scene;
			with (_caster) {
				coolingDown = true;
				var _callback = call_later(cooldown, time_source_units_seconds, function() {coolingDown = false;});
				async_callback(_scene);
			};
		} else {
			//NOT ENOUGH STATS TO USE SKILL LOGIC HERE
		};
	};
};
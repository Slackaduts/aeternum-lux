enum colliderShapes {
	SQUARE,
	ELLIPSE,
	LAST	
};


//function spawn_skill_collider(_caster = other.id, _sceneOnHit = [], _stats = new CombatStats(), _target = skillTarget.ENEMIES, _width = 64, _height = 64, _shape = colliderShapes.SQUARE, _infront = false, _addDist = 0, _theta = 0) {
//	var _hitboxData = {
//		caster: _caster,
//		target: _target,
//		sceneOnHit: _sceneOnHit,
//		stats: _stats,
//		infront: _infront,
//		addDist: _addDist,
//		theta: _theta,
//		width: _width,
//		height: _height,
//		shape: _shape,
//	};
	
//	return create_skill_collider(_hitboxData);
//};



function CombatSkill(_name, _desc, _scene, _triggerStats, _hitboxData = {}, _cooldown = 1, _cost = new CombatStats(), _target = skillTarget.ENEMIES) constructor {
	name = _name;
	desc = _desc;

	scene = _scene;

	stats = _triggerStats;
	cost = _cost;

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
	
	static cast = function(_caster = other, _override = false) {
		if is_castable(_caster) || _override {
			_caster.combatant.liveStats.revokeStats(cost);
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


function scene_damage_indicator(_hitOrigin, _dmg, _maxHp, _callbackIndex): scene_callback(undefined, _callbackIndex) constructor {
	hitOrigin = _hitOrigin;
	dmg = _dmg;
	maxHp = _maxHp;
	
	static initialize = function() {
		
	};
	
	
};
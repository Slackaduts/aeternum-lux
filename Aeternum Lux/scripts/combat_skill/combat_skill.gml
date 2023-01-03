enum colliderShapes {
	SQUARE,
	ELLIPSE,
	LAST	
};

function create_skill_collider(_hitboxData, _infront = false, _relX = 0, _relY = 0, _relTheta = 0, _shape = colliderShapes.ELLIPSE) {
	var _sprite = undefined;
	switch _shape {
		case colliderShapes.ELLIPSE:
			_sprite = sprColliderEllipse;
			_hitboxData.image_xscale = _hitboxData.hitboxWidth / 500;
			_hitboxData.image_yscale = _hitboxData.hitboxHeight / 500;
		break;
	
		default:
			_sprite = sprColliderSquare;
			_hitboxData.image_xscale = _hitboxData.hitboxWidth / 2;
			_hitboxData.image_yscale = _hitboxData.hitboxHeight / 2;
	};
	
	_hitboxData.sprite_index = _sprite;
	
	var _x = 0, _y = 0;
	
	if infront {
		_x = _hitboxData.caster.x - (_hitboxData.hitboxWidth * dsin(_hitboxData.caster.inputDirection));
		_y = _hitboxData.caster.y - (_hitboxData.hitboxHeight * dcos(_hitboxData.caster.inputDirection));
	} else {
		_x = rotate_point_x(_hitboxData.caster.x, _hitboxData.caster.y, _hitboxData.caster.x + _relX, _hitboxData.caster.y + _relY, _relTheta);
		_y = rotate_point_y(_hitboxData.caster.x, _hitboxData.caster.y, _hitboxData.caster.x + _relX, _hitboxData.caster.y + _relY, _relTheta);
	};

	return instance_create_depth(_x, _y, 0, objSkillHitbox, _hitboxData);
};


function SkillCollider(_width, _height, _caster, _scene, _target, _shape, _theta = 0, _distance = 0, infront = true) {
	
	
	
	
	
	
};



function CombatSkill(_name, _desc, _scene, _triggerStats, _hitboxData = {}, _cooldown = 1, _costStats = new CombatStats(), _target = skillTarget.ENEMIES, _hitboxObj = objSkillHitbox) constructor {
	name = _name;
	desc = _desc;

	scene = _scene;

	stats = _triggerStats;
	cost = _costStats;

	cooldown = _cooldown;
	coolingDown = false;

	target = _target;

	hitbox = undefined;
	hitboxObj = _hitboxObj;
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
	
	static cast = function(_caster = other) {
		if is_castable(_caster) {
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
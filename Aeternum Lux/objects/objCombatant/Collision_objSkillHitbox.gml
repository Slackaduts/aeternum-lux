/// @desc Skill hitbox handling

var _checkedHitboxes = [];
var _hitbox = undefined;
for (var _index = 0; _index < instance_number(objSkillHitbox); _index++) {
	var _inst = instance_nearest(x, y, objSkillHitbox);
	if item_index(_inst.hitInstances, id) == undefined {
		var _hitboxData = {
			inst: _inst,
			x: _hitbox.x,
			y: _hitbox.y
		};
		_inst.x = -1000000;
		_inst.y = -1000000;
		array_push(_checkedHitboxes, _hitboxData);
	} else {
		_hitbox = _inst;
		break;
	};
};

if _hitbox != undefined {
	combatant.liveStats.applyStats(_hitbox.stats);
	array_push(_hitbox.hitInstances, id);
	async_callback(_hitbox.sceneOnHit);	
};


for (var _index = 0; _index < array_length(_checkedHitboxes); _index++) {
	var _hitboxData = _checkedHitboxes[_index];
	var _inst = _hitboxData.inst;
	_inst.x = _hitboxData.x;
	_inst.y = _hitboxData.y;
};
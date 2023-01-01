enum skillTarget {
	SELF,
	ALLIES,
	ENEMIES,
	EVERYONE,
	LAST
};


function CombatSkill(_name, _desc, _scene, _triggerStats, _costStats = new CombatStats(), _target = skillTarget.ENEMIES) constructor {
	name = _name;
	desc = _desc;
	scene = _scene;
	stats = _triggerStats;
	cost = _costStats;
	target = _target;
	
	static cast = function(_caster = other) {
		if _caster.combatant.liveStats.hasStats(stats) {
			_caster.combatant.liveStats.revokeStats(stats);
			var _scene = scene;
			with (_caster) {
				async_callback(_scene);
			};
		} else {
			//NOT ENOUGH STATS TO USE SKILL LOGIC HERE
		};
	};
};
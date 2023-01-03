enum teamStates {
	NEUTRAL,
	PLAYER,
	ENEMY,
	LAST	
};

enum skillTarget {
	SELF,
	ALLIES,
	ENEMIES,
	EVERYONE,
	LAST
};



/**
 * Returns whether or not the targeting of a skill affects an instance.
 * @param {any*} _target The targeting enum value, see skillTarget
 * @param {any*} _caster The instance of the caster of the skill
 * @param {id.instance} [_inst]=other The instance to check if the skill affects
 * @returns {bool} Returns true if the skill affects the instance, false if otherwise.
 */
function skill_affects_inst(_target, _caster, _inst = other) {
	if _caster == undefined || _inst == undefined return false;
	switch (_target) {
		case skillTarget.SELF:
			return _caster.id == _inst.id;
		break;
		
		case skillTarget.ALLIES:
			return _caster.combatant.team == _inst.combatant.team;
		break;
		
		case skillTarget.ENEMIES:
			return _caster.combatant.team != _inst.combatant.team;
		break;
		
		default:
			return true;
	};
};
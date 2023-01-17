enum controlStates {
	STATIC,
	IDLE,
	CONTROLLED,
	FOLLOWING,
	WANDERING,
	LAST	
};


enum aiTypes {
	DARING,
	CAREFUL,
	SNIPER,
	NONE,
	LAST	
};


enum enemyRanks {
	MOB,
	ELITE,
	BOSS,
	ELDER,
	LAST	
};


enum aiStates {
	ATTACKING,
	HEALING,
	DEFENDING,
	RUSHING,
	FLEEING,
	LAST
};



/**
 * Creates a struct containing the relevant combatant states useful for handling movement and other things outside of combat.
 */
function CombatStates() constructor {
	inCombat = false; //If we are in combat
	isDead = false; //If our HP is 0
	isLocked = false; //If our movement is locked
	isDocile = false; //If we are forced into not attacking
	isSlowed = false; //If we are slowed
	isConfused = false; //If we are forced into random directions
	controlState = controlStates.IDLE
};


/**
 * Creates a struct containing stats relevant to combat for a combatant.
 */
function CombatStats() constructor {
	maxHp = 0; //Max Health
	hpRegen = 0; //Health regeneration
	hp = 0; //Current Health
	maxMp = 0; //Max Mana
	mpRegen = 0; //Mana regeneration
	mp = 0; //Current Mana
	maxTp = 0; //Max TP
	tp = 0; //Current TP, allows some skills to be used and also passively buffs all attacks
	vigor = 0; //Attack
	affinity = 0; //Magic Attack
	fortitude = 0; //Defense
	resilience = 0; //Magic Defense
	technique = 0; //Reduces cooldowns for skills and mildly improves TP gain
	tenacity = 0; //Working name, mildly improves all stats when solo and improves defensive stats greatly when in a party but NOT selected
	
	/// @desc Clamps stats to be within their relevant ranges.	
	static clampStats = function() {
		//NOTE: This clamp is sus as fuck
		clamp_struct(self, 0, 999999);
		hp = clamp(hp, 0, maxHp);
		mp = clamp(mp, 0, maxMp);
		tp = clamp(tp, 0, maxTp);
	};
	
	static setStats = function(_statsMod) {
		add_struct(self, _statsMod);
	};
	
	
	/**
	 * Adds stats to this CombatStats object.
	 * @param {struct.CombatStats} _statsMod Stats to apply
	 */
	static applyStats = function(_statsMod) {
		add_struct(self, _statsMod);
		clampStats();
	};
	
	
	/**
	 * Checks if this stat struct is greater than or equal to another stat struct.
	 * @param {struct} _stats Stats to check if we have
	 * @returns {bool} Returns true if we have these stats, false if not
	 */
	static hasStats = function(_stats) {
		_names = variable_struct_get_names(_stats);
		for (var _index = 0; _index < array_length(_names); _index++) {
			var _name = _names[_index];
			if !(variable_struct_exists(self, _name) && self[$ _name] >= _stats[$ _name]) return false;
		};

		return true;
	};
	

	/**
	 * Subtracts stats from this CombatStats object.
	 * @param {struct.CombatStats} _statsMod Stats to revoke
	 */
	static revokeStats = function(_statsMod) {
		subtract_struct(self, _statsMod);
		clampStats();
	};
};




/**
 * Holds all combat-related information for a combatant.
 * @param {any*} _name Name of this combatant
 */
function CombatantManager(_name) constructor {
	name =_name;
	team = teamStates.ENEMY;
	rank = enemyRanks.MOB;
	level = 1;
	aiType = aiTypes.DARING;
	states = new CombatStates();
	sightRange = 320;
	agro = false;
	//agroCallback = undefined;

	inst = other.id;
	title = undefined;
	healthbar = undefined;

	baseStats = new CombatStats();
	liveStats = new CombatStats();
	
	equipment = [];
	overTimes = [];
	
	static update = function() {
		show_debug_message(0)
		if global.focusObject == undefined || team == global.focusObject.combatant.team exit;
		title ??= instance_create_depth(0, 0, 0, yui_document, {yui_file: "YUI/Screens/mob_name.yui", data_context: {inst: inst}});
		healthbar ??= instance_create_depth(0, 0, 0, yui_document, {yui_file: "YUI/Screens/mob_healthbar.yui", data_context: {inst: inst}});
		show_debug_message(1)

		if agro {
			show_debug_message(2)
			//if agroCallback == undefined exit;
			with (inst) var _dist = distance_to_object(global.focusObject);
			show_debug_message(3)
			if _dist > 320 || collision_line(inst.x, inst.y, global.focusObject.x, global.focusObject.y, objTile, true, true) != noone {
				show_debug_message(4)
				agro = false;
				//instance_destroy(title);
				//title = undefined;
			};
		
		} else {
			show_debug_message(5)
			with (inst) var _dist = distance_to_object(global.focusObject);
			show_debug_message(6)
			if _dist <= 320 {
				show_debug_message(7)
				if collision_line(inst.x, inst.y, global.focusObject.x, global.focusObject.y, objTile, true, true) == noone {
					show_debug_message(8)
					agro = true;
					//agroCallback = call_later(5, time_source_units_seconds, function() {agroCallback = undefined;}, false);
					
				};
			};
		};
	};
};
/// @desc Updates the main ppfx profile in the desired object.
/// @param {asset.GMObject} [_obj]=objCamera Object holding the ppfx manager/profiles. Defaults to the camera object.
function update_main_ppfx(_obj = objCamera) {
	var _inst = instance_find(_obj, 0);
	with (_inst) {
		main_profile = ppfx_profile_create("Main", ppfx_effects.get_array());
		ppfx_profile_load(ppfx_id, main_profile);
	};
};



/**
 * Creates a callback that adds a list of PPFX effects to the current profile, and removes them when finished. TODO: TWEENING SUPPORT
 * @param {any*} _data Duration of the PPFX effects
 * @param {array} _effects Array of PPFX effects to use
 * @param {real} [_callbackIndex]=0 Index to go to afterwards, see other function docs on usage
 */
function scene_timed_ppfx_effects(_data, _effects, _callbackIndex = 0): scene_callback(_data, _callbackIndex) constructor {
	effectIndexes = [];
	effects = _effects;
	
	static initialize = function() {
		var _inst = instance_find(objCamera, 0);
		for (var _index = 0; _index < array_length(effects); _index++) {
			array_push(effectIndexes, _inst.ppfx_effects.add_item(effects[_index]));
		};
		update_main_ppfx();
		var _callback = call_later(data, time_source_units_seconds, function() {self.finish();});
	};
		
	static finish = function() {
		var _inst = instance_find(objCamera, 0);
		for (var _index = 0; _index < array_length(effectIndexes); _index++) {
			_inst.ppfx_effects.remove_item(effectIndexes[_index]);
		};
		update_main_ppfx();
		completed = true;
	};
};


/// @desc Tweens an array of Foxy PPFX effects using an animation curve
/// @param {real} _duration How long the entire effect should be active
/// @param {real} _tweenDuration How long it takes to individually fade in/out
/// @param {array} _effects Array of PPFX effects
/// @param {array<string>} _params Array of parameters to change over time for each effect
/// @param {array<real>} _starts Array of starting values
/// @param {array<real>} _finishes Array of ending values
/// @param {string} [_shape]="Linear" Shape of the curve, defined in anim_tweens
/// @param {real} [_callbackIndex]=0 Index to go to afterwards, see other function docs on usage
function scene_tween_ppfx_effects(_duration, _tweenDuration, _effects, _params, _starts, _finishes, _shape = "Linear", _callbackIndex = 0): scene_timed_ppfx_effects(_duration, _effects, _callbackIndex) constructor {
	params = _params;
	starts = _starts;
	finishes = _finishes;
	duration = _duration;
	tweenDuration = _tweenDuration;
	tweenCurve = animcurve_get_channel(anim_tweens, _shape);
	tweenIncrement = 1 / (tweenDuration * FRAME_RATE);
	tweenPercent = 0;
	finishedTween = false;
	
	
	/**
	 * Adds effects to the main PPFX profile, and starts the finish callback countdown.
	 */
	static initialize = function() {
		var _inst = instance_find(objCamera, 0);
		for (var _index = 0; _index < array_length(effects); _index++) {
			array_push(effectIndexes, _inst.ppfx_effects.add_item(effects[_index]));
		};
		update_main_ppfx();
		var _callback = call_later(data, time_source_units_seconds, function() {self.finish();});
	};
	
	
	/**
	 * Updates the effect with the animation curve provided.
	 */
	static run = function() {
		if !finishedTween {
			tweenPercent += tweenIncrement;
			if tweenPercent > 1 || tweenPercent < 0 {
				finishedTween = true;
				tweenIncrement *= -1;
				if tweenPercent > 1 var _callback = call_later(data - (tweenDuration * 2), time_source_units_seconds, function() {finishedTween = false;});
			};
		
			var _tweenPosition = animcurve_channel_evaluate(tweenCurve, tweenPercent);

			var _inst = instance_find(objCamera, 0);
			for (var _index = 0; _index < array_length(effects); _index++) {
				var _effect = effects[_index];
				var _param = params[_index];
				var _startParam = starts[_index];
				var _finishParam = finishes[_index];
				var _effectIndex = effectIndexes[_index];
			
				var _dist = _finishParam - _startParam;
				if variable_struct_exists(_inst.ppfx_effects, string(_effectIndex)) _inst.ppfx_effects[$ string(_effectIndex)].sets[$ _param] = _startParam + (_dist * _tweenPosition);
			};
			update_main_ppfx();
		};
	};
	
	
	/**
	 * Removes the effects from the main Foxy PPFX profile.
	 */
	static finish = function() {
		var _inst = instance_find(objCamera, 0);
		for (var _index = 0; _index < array_length(effectIndexes); _index++) {
			_inst.ppfx_effects.remove_item(effectIndexes[_index]);
		};
		update_main_ppfx();
		completed = true;
	};
	
	/**
	 * Resets this callback so it can be run again.
	 */
	static reset = function() {
		tweenIncrement = 1 / (tweenDuration * FRAME_RATE);
		tweenPercent = 0;
		finishedTween = false;
		completed = false;
	};
};
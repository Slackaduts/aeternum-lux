/// @desc Manages and runs a series of sequential predetermined events semi-asynchronously. 
/// @param {array<struct.scene_callback>} _callbacks Array of callbacks, in chronological order
function scene_manager(_callbacks) constructor {
	callbacks = _callbacks;
	callbackIndex = 0;
	scenePlaying = false;
	sceneOver = false;

	
	/**
	 * Advances the scene manager to the next scene if the first is completed. Handles graceful finish of past callback, and initializes the future one.
	 */
	static advance = function() {
		//if !is_array(callbacks) || array_length(callbacks) == 0 exit;
		var _callback = callbacks[callbackIndex];
		if _callback.completed {
			_callback.finish();
			_callback.index ??= callbackIndex + 1;
			if _callback.index == 0 _callback.index = callbackIndex + 1;
			callbackIndex = _callback.index;
			_callback.reset();
			scenePlaying = false;
			if callbackIndex >= array_length(callbacks) || callbackIndex < 0 {
				if callbackIndex < 0 callbackIndex = abs(_callback.index);
				else callbackIndex = 0;
				sceneOver = true;
			} else {
				run();
			};
		};
	};

	/**
	 * Runs the scene manager for one frame.
	 */
	static run = function() {
		if !is_array(callbacks) show_debug_message(callbacks);
		//if !is_array(callbacks) || array_length(callbacks) == 0 exit;
		var _callback = callbacks[callbackIndex];
		var _initialized = false;
		sceneOver = false;
		if !scenePlaying {
			_callback.initialize();
			_initialized = true;
			scenePlaying = true;
		};

		if !_initialized {
			_callback.run();
			advance();
		};
	};
};


/**
 * Creates a "pool" of scene managers that update in real time, and close themselves when finished. Emulates async events.
 */
function scene_pool() constructor {
	scenes = [];
	
	/**
	 * Runs every scene, every frame.
	 */
	static run = function() {
		var _scenes = scenes;
		if array_length(_scenes) <= 0 exit;
		for (var _index = 0; _index < array_length(_scenes); _index++) {
			var _scene = _scenes[_index];
			_scene.run();
			if _scene.sceneOver array_delete(scenes, _index, 1);
		};
	};
	
	/**
	 * Adds a scene to the scene pool. Execution will begin immediately on this or the next frame.
	 * @param {array<struct.scene_callback>} _scene Array of scene callbacks to push to the scene pool
	 */
	static add_scene = function(_scene) {
		array_push(scenes, new scene_manager(_scene));
	};
};


/// @desc Creates a framework of a scene callback. Does nothing.
/// @param {any*} [_data] Data to be supplied to the callback, does nothing.
/// @param {real} [_index] Index of the callback array in the parent scene manager to skip to. Influences branching scene logic.
function scene_callback(_data = undefined, _index = 0) constructor {
	data = _data;
	index = _index;
	completed = false;
	
	/**
	 * Code that runs before the scene callback begins.
	 */
	static initialize = function() {};

	/// @desc Code that runs when the scene manager runs. Typically this happens every frame.
	static run = function() {};

	/**
	 * Marks this callback as completed so the scene manager can move on.
	 */
	static finish = function() {
		completed = true;
	};

	/**
	 * Resets this callback to the original, uninitialized state.
	 */
	static reset = function() { //runs after completion to reset back to original state
		completed = false;
	};
};




/**
 * Pushes a scene to the scene pool for execution, not waiting for its execution to finish in the current scene manager.
 * @param {any*} _scene Scene to execute
 * @param {real} [_index] Index to go to upon completion, influences branching scene logic
 */
function async_callback(_scene, _index = 0): scene_callback(_scene, _index) constructor {
	/**
	 * Adds this scene to the scene pool.
	 */
	static initialize = function() {
		other.scenePool.add_scene(data);
		finish();
	};
};



/**
 * Creates a scene callback for showing dialogue. Must be added to a scene pool and/or scene manager to actually do something.
 * @param {any*} _speaker The object "speaking" the dialogue
 * @param {string} [_data]="" String of dialogue to show
 * @param {real} [_index] Index to go to afterwards. Negative indexes mark a default to change the scene manager to. Example: -9 means after completion, the scene manager will reset and set index 9 as the start.
 */
function scene_dialogue(_speaker, _data = "", _index = 0): scene_callback(_data, _index) constructor {
	speaker = _speaker;
	typist = undefined;
	yui = undefined;	
	
	/**
	 * Initializes the dialogue object, and the scribble typist.
	 */
	static initialize = function() {
		typist = scribble_typist();
		typist.in(1, 1);
		yui = instance_create_depth(0, 0, 0, yui_document, {yui_file: "YUI/Screens/dialogue.yui", data_context: other});
	};
	
	/**
	 * Runs the dialogue, checking for user input. Typically ran every frame.
	 */
	static run = function() {
		if input_check_pressed("accept") && typist.get_state() >= 1 {
			instance_destroy(yui, true);
			finish();
		};
	};
	
	/**
	 * Resets this callback to the original, uninitialized state. 
	 */
	static reset = function() {
		completed = false;
		typist = undefined;
		yui = undefined;
	};
};


/**
 * Creates a callback that finishes after a specified period of time, in seconds.
 * @param {real} [_data]=1 Duration of the callback
 * @param {real} [_index]=0 Index to go to afterwards, see other function docs on usage
 */
function scene_delay(_data = 1, _index = 0): scene_callback(_data, _index) constructor {
	static initialize = function() {
		var _callback = call_later(data, time_source_units_seconds, function() {self.finish();});
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


//function tween_ppfx(_tweenDuration, _effects, _params, _start, _finish) constructor {
	
	
	
//};


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
	
	
	static initialize = function() {
		var _inst = instance_find(objCamera, 0);
		for (var _index = 0; _index < array_length(effects); _index++) {
			array_push(effectIndexes, _inst.ppfx_effects.add_item(effects[_index]));
		};
		update_main_ppfx();
		var _callback = call_later(data, time_source_units_seconds, function() {self.finish();});
	};
	
	
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
	
	
	static finish = function() {
		var _inst = instance_find(objCamera, 0);
		for (var _index = 0; _index < array_length(effectIndexes); _index++) {
			_inst.ppfx_effects.remove_item(effectIndexes[_index]);
		};
		update_main_ppfx();
		completed = true;
	};
	
	static reset = function() {
		tweenIncrement = 1 / (tweenDuration * FRAME_RATE);
		tweenPercent = 0;
		finishedTween = false;
		completed = false;
	};
};




function dialogue_option() constructor {
};



function scene_dialogue_options(_speaker, _options = [], _data = "", _index = 0): scene_dialogue(_speaker, _data, _index) constructor {
	options = _options;
	
};
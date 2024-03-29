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
	static run = function() {
		finish();
	};

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
 * Sends a scene callback to a specified instance's scenepool for execution.
 * @param {Id.Instance} _inst Instance to send the scene to
 * @param {any*} _scene Scene to send
 * @param {real} [_index]=0 Index to go to upon completion, influences branching scene logic
 */
function send_callback(_inst, _scene, _index = 0): scene_callback(_scene, _index) constructor {
	parent = _inst;

	/**
	 * Adds this scene to the scene pool of the parent instance.
	 */
	static initialize = function() {
		parent.scenePool.add_scene(data);
		finish();
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
	
	static run = function() {};
};



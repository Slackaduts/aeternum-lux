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


function dialogue_option() constructor {
};



function scene_dialogue_options(_speaker, _options = [], _data = "", _index = 0): scene_dialogue(_speaker, _data, _index) constructor {
	options = _options;
	
};
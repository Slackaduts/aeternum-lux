function scene_manager(_callbacks) constructor {
	callbacks = _callbacks;
	callbackIndex = 0;
	//startingIndex = callbackIndex;
	scenePlaying = false;
	sceneOver = false;

	
	static advance = function() { //runs only when the current callback finishes
		var _callback = callbacks[callbackIndex];
		if _callback.completed {
			_callback.finish();
			_callback.index ??= callbackIndex + 1;
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

	static run = function() { //runs every frame
		//if callbackIndex >= array_length(callbacks) callbackIndex = postSceneIndex;
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


//function scene_pool(_callbacks): scene_manager(_callbacks) constructor {

//	static advance = function() {
//		array_delete(callbacks, callbackIndex, 1);
//	};
	
//	static run = function() {
//		for (callbackIndex = 0; callbackIndex < array_length(callbacks); callbackIndex++) {
//			scenePlaying = true;
//			var _callback = callbacks[callbackIndex];
//			_callback.run();
//		};
//		if array_length(callbacks) == 0 scenePlaying = false;
//	};
	
//	static initialize = function() {};
//};


function scene_callback(_data = undefined, _index = undefined) constructor {
	data = _data;
	index = _index;
	completed = false;
	
	static initialize = function() {}; //runs once
	
	static run = function() {}; //runs every frame
	
	static finish = function() { //marks this callback as completed so the scene manager can advance
		completed = true;
	};
	
	static reset = function() { //runs after completion to reset back to original state
		completed = false;
	};
};



function scene_dialogue(_speaker, _data = "", _index = undefined): scene_callback(_data, _index) constructor {
	speaker = _speaker;
	typist = undefined;
	yui = undefined;	
	
	static initialize = function() {
		typist = scribble_typist();
		typist.in(1, 1);
		yui = instance_create_depth(0, 0, 0, yui_document, {yui_file: "\\YUI\\Screens\\dialogue.yui", data_context: other});
	};
	
	static run = function() {
		if input_check_pressed("accept") && typist.get_state() >= 1 {
			instance_destroy(yui, true);
			finish();
		};
	};
	
	static reset = function() {
		completed = false;
		typist = undefined;
		yui = undefined;
	};
};


//function scene_options(_data): scene_callback(_data) constructor {
	
	
//};
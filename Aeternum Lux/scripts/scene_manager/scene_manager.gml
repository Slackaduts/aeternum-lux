function scene_manager(_callbacks) constructor {
	callbacks = _callbacks;
	callbackIndex = 0;
	sceneOver = false;

	static advance = function() {
		callbackIndex += 1;
		if callbackIndex >= array_length(callbacks) {
			sceneOver = true

		} else {
			var _callback = callbacks[callbackIndex];
			_callback.initialize();

		};
	};
	
	static run = function() { //runs every frame
		if !sceneOver {
			var _callback = callbacks[callbackIndex];
			_callback.run();

		} else delete self;
	};
};


function scene_callback(_data = undefined) constructor {
	sceneManager = other;
	data = _data;
	
	static initialize = function() {}; //runs once
	
	static run = function() {}; //runs every frame
	
	static finish = function() { //advances the scene manager
		sceneManager.advance();
	};
};


function scene_dialogue(_speaker, _data = ""): scene_callback(_data) constructor {
	speaker = _speaker;
	typist = scribble_typist();
	yui = undefined;
	
	static initialize = function() {
		typist.in(1, 0);
		var _yui_data = {yui_file: "\\YUI\\Screens\\dialogue.yui", data_context: other};
		yui = instance_create_depth(0, 0, 0, yui_document, _yui_data);
	};
	
	static run = function() {
		var _skipped = false;
		var _pressed = input_check_pressed("accept");

		if _pressed {
			_skipped = true;
			typist.skip();
		};

		if !_skipped && typist.get_state() >= 1 && _pressed {
			instance_destroy(yui, true);
			finish();
		};
	};
};
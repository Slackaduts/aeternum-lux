// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information


//CUTSCENE ENTRY FORMAT: [nextIndex, waitFor (bool), function, [args]]


/// @desc Creates a new scene manager with a provided list of scene arrays.
/// @param {array<array>} [_scenes]=[[]] Array of scene, of which each scene part is an array
function scene_manager(_scenes = [[]]) constructor {
	scenes = _scenes;
	sceneOver = true;
	cutsceneOver = false;
	cutscenePlaying = false;
	currScene = 0;
	_scribble = undefined;
	_typist = undefined;
	_yui = undefined;
	
	static scene_execute = function(_scene = currScene, _forced = false) {
		if sceneOver || _forced {
			cutsceneOver = false;
			cutscenePlaying = true;
			script_execute_ext(scenes[_scene][2], scenes[_scene][3]);
			if scenes[_scene][1] {
				sceneOver = false;
			};
		};
	};
	
	static next_scene = function(_forcedScene = currScene) {
			sceneOver = true;
			currScene = scenes[_forcedScene][0];
	
			if abs(currScene) >= array_length(scenes) {
				cutscenePlaying = false;
				cutsceneOver = true;
				currScene = 0;
				
				if _yui != undefined {
					instance_destroy(_yui);
					_yui = undefined;
				};
			};
	};
	
	static npc_activate_scene = function(_inputKey = "accept") {
		with (other) {
			if objFocusIndicator.focusObj == id {
				if (sceneManager._yui == undefined && input_check_pressed(_inputKey)) || sceneManager.cutscenePlaying {
					if sceneManager.sceneOver {
						if sceneManager.currScene != array_length(sceneManager.scenes) - 1 sceneManager.scene_execute(sceneManager.currScene);
					};
				};
			};
			
			
			if sceneManager.cutscenePlaying objFocusIndicator.indicatorState = indicatorStates.INVISIBLE
			else if sceneManager.cutsceneOver objFocusIndicator.indicatorState = indicatorStates.TALK
			else objFocusIndicator.indicatorState = indicatorStates.ALERT;
		};
	};
	
	static push_to_scene_pool = function(_obj = other) {
		array_push(_obj.scenePool, self);
	};
};


//function get_empty_gui_x(_speakerObj, _objs = []) {
	
	
	
//};


function dialogue_manager(_callerObj, _speakerObj, _content = "", _txtSpd = 1, _txtSmoothness = 0, _forceSkip = false) constructor {
	forceSkip = _forceSkip;
	caller = _callerObj;
	speaker = _speakerObj;
	content = _content;
	typist = scribble_typist();
	typist.in(_txtSpd, _txtSmoothness);
	dialogueEnd = false;
	
	//if !forceSkip {
	//	content = content + "\n[pin_center][sprFocusIndicator]";
	//};
	
	static can_advance = function() {
		dialogueEnd = (typist.get_state() == 1);
	};
	
	static advance = function(_key = "accept") {
		can_advance();
		if dialogueEnd && (input_check(_key) || forceSkip) caller.sceneManager.next_scene();
	};
};


function cutscene_dialogue(_callerObj, _speakerObj, _content = "", _txtSpd = 1, _txtSmoothness = 0, _forceSkip = false, _obj = objDialogue) {
	with (_callerObj) {
		if sceneManager._yui != undefined {
			instance_destroy(sceneManager._yui);
			sceneManager._yui = undefined;
		};
		
		var _params = { data_context: new dialogue_manager(_callerObj, _speakerObj, _content, _txtSpd, _txtSmoothness, _forceSkip) };
		sceneManager._yui = instance_create_depth(x, y, 0, _obj, _params);
		//sceneManager._yui.load();
	};
};

function cutscene_toggle_movement(_callerObj, _forcedStatus = undefined) {
	//TODO: MAKE THIS WORK
	if _forcedStatus != undefined {
		global.movementStatus = !global.movementStatus;
	} else global.movementStatus = _forcedStatus;
	
	_callerObj.sceneManager.next_scene();
};

/// @desc Moves an object to a specific XY over a period of time. Also allows for relative movement by default.
/// @param {Id.Instance*} _obj The instance we are moving
/// @param {real*} _duration The duration of the movement
/// @param {real} _x the X position we are moving to/by
/// @param {real} _y the Y position we are moving to/by
/// @param {string} [_curve]="Linear" The tweening curve, found in anim_tweens
/// @param {bool} [_relative]=true Whether the provided XY is absolute or relative
function cutscene_move_object(_obj, _duration, _x, _y, _curve = "Linear", _relative = true) {
	with (_obj) {
		var originX = 0,
			originY = 0;
		if _relative {
			originX = x;
			originY = y;
		};
		var _tween = new NumberTween(_duration, [originX, originY], [originX + _x, originY + _y], TWEEN_XY, _curve, sceneManager.next_scene);
		tweenManager.add(_tween);
	};
};



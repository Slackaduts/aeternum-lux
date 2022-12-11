/// @desc Returns a struct of saveable data from an instance. 
/// @param {Id.Instance} _inst Description
/// @returns {struct}
function get_instance_data(_inst) {
	var _instData = {};
	if variable_instance_exists(_inst, "dataToSave") {
		var _relevantData = _inst.dataToSave;
		_instData.spawnObjName = object_get_name(_inst.object_index);
		for (var _index = 0; _index < array_length(_relevantData); _index++) {
			var _name = _relevantData[_index];
			_instData[$ _name] = _inst[$ _name];
		};
	};
	
	return _instData;	
};
//TODO: Change room saving to use objectsToSave like it was before the wipe DONE
// -- Clear Room function DONE
// --Finish room and player data functions


function load_instance(_obj, _instData) {
	var _inst = instance_create_depth(0, 0, 0, _obj);
	var _instDataNames = variable_struct_get_names(_instData);
	with (_inst) {
		for (var _index = 0; _index < array_length(_instDataNames); _index++) {
			var _data = _instDataNames[_index];
			self[$ _data] = _instData[$ _data];
		};
	};
};


function temp_save_current_room(_objsToSave = [objCombatant, objCamera]) {
	var _roomName = room_get_name(room);
	global.roomData[$ _roomName] = [];
	for (var _currObj = 0; _currObj < array_length(_objsToSave); _currObj++) {
		var _obj = _objsToSave[_currObj];
		for (var _index = 0; _index < instance_number(_obj); _index++) {
			var _inst = instance_find(_obj, _index);
			var _instData = get_instance_data(_inst);
			if _instData != {} array_push(global.roomData[$ _roomName], _instData);
		};
	};
};


function write_room(_roomName, _cleanup = false) {
	if !directory_exists("saveData") directory_create("saveData");
	var _filepath = string_concat("saveData\\roomData\\", _roomName, ".yml");
	if !variable_struct_exists(global.roomData, _roomName) exit;
	
	var _snap = SnapToYAML(global.roomData[$ _roomName]);
	SnapStringToFile(_snap, _filepath);
	
	if _cleanup delete global.roomData[$ _roomName];
};


function read_room(_roomName) {
	var _filepath = string_concat("saveData\\roomData\\", _roomName, ".yml");
	if !file_exists(_filepath) exit;
	
	var _snap = SnapStringFromFile(_filepath);
	global.roomData[$ _roomName] = SnapFromYAML(_snap);	
};


function load_room(_roomName, _cleanup = true) {
	if !variable_struct_exists(global.roomData, _roomName) {
		read_room(_roomName);
		if !variable_struct_exists(global.roomData, _roomName) exit;
	};
	
	clear_room();
	for (var _index = 0; _index < array_length(global.roomData[$ _roomName]); _index++) {
		var _objName = global.roomData[$ _roomName][_index].spawnObjName;
		show_debug_message(_objName);
		if _objName != undefined {
		var _obj = asset_get_index(string(_objName));
		load_instance(_obj, global.roomData[$ _roomName][_index]);
		};
	};
	
};


function clear_room() {
	for (var _index = 0; _index < instance_count; _index++) {
		var _inst = instance_id[_index];
		if variable_instance_exists(_inst, "dataToSave") instance_destroy(_inst, true);
	};	
};


function temp_save_player_data() {
 	var _partyNames = []
	for (var _index = 0; _index < array_length(global.partyObjects); _index++) {
		array_push(_partyNames, object_get_name(global.partyObjects[_index]));
	};
	
	var _focusName = object_get_name(global.focusInstance.object_index);

	global.saveData = {
		partyNames: _partyNames,
		focusName: _focusName,
		movementStatus: global.movementStatus,
		currentRoom: room_get_name(room)
	};
};


function load_player_data() {
	if variable_struct_get_names(global.saveData) == 0 {
		read_player_data();	
	};
	
	//show_debug_message(global.saveData);
	
	global.partyObjects = [];
	for (var _index = 0; _index < array_length(global.saveData.partyNames); _index++) {
		array_push(global.partyObjects, asset_get_index(global.saveData.partyNames[_index]));
	};
	
	global.focusObject = asset_get_index(global.saveData.focusName);
	global.movementStatus = global.saveData.movementStatus;
};
	



function write_player_data() {
	var _dir = "saveData";
	if !directory_exists(_dir) directory_create(_dir);
	var _filepath = string_concat(_dir, "\\", _dir, ".yml");
	var _snap = SnapToYAML(global.saveData);
	SnapStringToFile(_snap, _filepath);
};


function read_player_data() {
	var _filepath = "saveData\\saveData.yml";
	if !file_exists(_filepath) exit;
	var _snap = SnapStringFromFile(_filepath);
	global.saveData = SnapFromYAML(_snap);
};



/**
 * Transfers the player to a given room and to a given position in that room.
 * @param {any*} _x Description
 * @param {any*} _y Description
 * @param {string} _roomName Description
 */
function room_transfer(_x, _y, _roomName) {
    temp_save_current_room();
    temp_save_player_data();
    room_goto(asset_get_index(_roomName));
    load_room(_roomName);
    load_player_data();

    for (var _index = 0; _index < array_length(global.partyObjects); _index++) {
        var _member = instance_find(global.partyObjects[_index], 0);
        _member.x = _x;
        _member.y = _y;
    };
};


/**
 * Top-level function for saving the game. Writes to files.
 */
function save_game() {
    temp_save_current_room();
    temp_save_player_data();
    write_player_data();
    var _roomNames = variable_struct_get_names(global.roomData);
    for (var _index = 0; _index < array_length(_roomNames); _index++) {
        var _roomName = _roomNames[_index];
        write_room(_roomName, false);
    };
};


/**
 * Top-level function for loading the game. Reads from files.
 */
function load_game() {
    load_player_data();
    room_goto(asset_get_index(global.saveData.currentRoom));
    load_room(global.saveData.currentRoom);
    load_player_data();
};
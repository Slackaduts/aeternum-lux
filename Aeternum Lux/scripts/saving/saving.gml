/// @desc Returns a struct of saveable data from an instance. 
/// @param {Id.Instance} _inst Instance to get the saveable data of
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


/**
 * Creates an instance and then overwrites specified values.
 * @param {asset.GMObject} _obj Object to create instance of
 * @param {struct} _instData Struct of variables to merge/overwrite
 */
function load_instance(_obj, _instData) {
	var _inst = instance_create_depth(0, 0, 0, _obj);
	var _instDataNames = variable_struct_get_names(_instData);
	with (_inst) {
		for (var _index = 0; _index < array_length(_instDataNames); _index++) {
			var _data = _instDataNames[_index];
			if is_struct(self[$ _data]) || is_array(self[$ _data]) merge_struct(self[$ _data], _instData[$ _data]);
			else self[$ _data] = _instData[$ _data];
		};
	};
};


/**
 * Saves the saveable data of the current room to memory. Does NOT write to file.
 * @param {array<asset.GMObject>} [_objsToSave]=[objCombatant, objCamera] Description
 */
function temp_save_current_room(_objsToSave = [objCombatant]) {
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


/**
 * Writes the saveable data of a specified room to file.
 * @param {any} _roomName Room to write to file, by name
 * @param {bool} [_cleanup]=false Whether we should delete the room data from memory afterwards
 */
function write_room(_roomName, _cleanup = false) {
	if !directory_exists("saveData") directory_create("saveData");
	var _filepath = string_concat("saveData\\roomData\\", _roomName, ".yml");
	if !variable_struct_exists(global.roomData, _roomName) exit;
	
	var _snap = SnapToYAML(global.roomData[$ _roomName]);
	SnapStringToFile(_snap, _filepath);
	
	if _cleanup delete global.roomData[$ _roomName];
};


/**
 * Read the saveable data of a room from file.
 * @param {any*} _roomName Room to read the data of, by name
 */
function read_room(_roomName) {
	var _filepath = string_concat("saveData\\roomData\\", _roomName, ".yml");
	if !file_exists(_filepath) exit;
	
	var _snap = SnapStringFromFile(_filepath);
	global.roomData[$ _roomName] = SnapFromYAML(_snap);	
};


/**
 * Loads a room from memory (or file if needed) into the game world.
 * @param {any} _roomName Room to load, by name
 * @param {bool} [_cleanup]=true Whether we should delete the room data from memory afterwards
 */
function load_room(_roomName, _cleanup = true) {
	if !variable_struct_exists(global.roomData, _roomName) {
		read_room(_roomName);
		if !variable_struct_exists(global.roomData, _roomName) exit;
	};
	
	clear_room();
	for (var _index = 0; _index < array_length(global.roomData[$ _roomName]); _index++) {
		var _objName = global.roomData[$ _roomName][_index].spawnObjName;
		if _objName != undefined {
		var _obj = asset_get_index(string(_objName));
		load_instance(_obj, global.roomData[$ _roomName][_index]);
		};
	};
	
};


/**
 * Clears all saveable instances from the room.
 */
function clear_room(_destructables = ["dataToSave"]) {
	for (var _index = 0; _index < instance_count; _index++) {
		var _inst = instance_id[_index];
		for (var _destruct = 0; _destruct < array_length(_destructables); _destruct++) {
			if variable_instance_exists(_inst, _destructables[_destruct]) {
				instance_destroy(_inst, true);
				break;
			};
		};
	};	
};


/**
 * Saves global and party data to memory. Does NOT write to file.
 */
function temp_save_player_data() {
 	var _partyNames = []
	var _partyData = [];
	for (var _index = 0; _index < array_length(global.partyObjects); _index++) {
		var _obj = global.partyObjects[_index];
		array_push(_partyNames, object_get_name(_obj));
		var _inst = instance_find(_obj, 0);
		array_push(_partyData, get_instance_data(_inst));
	};
	
	var _focusName = object_get_name(global.focusObject);

	global.saveData = {
		partyNames: _partyNames,
		partyData: _partyData,
		cameraData: get_instance_data(instance_find(objCamera, 0)),
		focusName: _focusName,
		movementStatus: global.movementStatus,
		currentRoom: room_get_name(room)
	};
};


/**
 * Loads global and party data from memory into the game world.
 */
function load_player_data() {
	if array_length(variable_struct_get_names(global.saveData)) == 0 {
		read_player_data();
	};
	
	global.partyObjects = [];
	for (var _index = 0; _index < array_length(global.saveData.partyNames); _index++) {
		var _obj = asset_get_index(global.saveData.partyNames[_index]);
		array_push(global.partyObjects, _obj);
		instance_destroy(_obj, true);
		load_instance(_obj, global.saveData.partyData[_index]);
	};
	
	if instance_exists(objCamera) instance_destroy(objCamera, true);
	load_instance(objCamera, global.saveData.cameraData);
	
	
	global.focusObject = asset_get_index(global.saveData.focusName);
	global.movementStatus = global.saveData.movementStatus;
	show_debug_message("THIS RAN")
	show_debug_message(room_get_name(room));
};


/**
 * Writes global and party data to file.
 */
function write_player_data() {
	var _dir = "saveData";
	if !directory_exists(_dir) directory_create(_dir);
	var _filepath = string_concat(_dir, "\\", _dir, ".yml");
	var _snap = SnapToYAML(global.saveData);
	SnapStringToFile(_snap, _filepath);
};


/**
 * Reads global and party data from file into memory.
 */
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
	//Save current room and player data to memory
    temp_save_current_room();
    temp_save_player_data();

	//Only change rooms if we aren't in the same room
	if _roomName != room_get_name(room) {
		clear_room(["dataToSave", "lights", "partSystem", "emitters"]);
		instance_destroy(objLightController, true);
		room_goto(asset_get_index(_roomName));
		//load_room(_roomName);
	};

	////Modify our saved location in the player data to match the desired one
	//for (var _index = 0; _index < array_length(global.saveData.partyData); _index++) {
	//	global.saveData.partyData[_index].x = _x;
	//	global.saveData.partyData[_index].y = _y;
	//};

	////Load in our party with the newly modified data
	//if !instance_exists(objLightController) instance_create_layer(0, 0, "LightRender", objLightController);
    //load_player_data();
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


/**
 * Overwrites a struct with another recursively, and preserves the methods on the original struct.
 * @param {struct} _struct Struct to overwrite
 * @param {struct} _dataStruct The data struct we are overwriting with
 */
function merge_struct(_struct, _dataStruct) {
	var _dataStructNames = variable_struct_get_names(_dataStruct);
	for (var _index = 0; _index < array_length(_dataStructNames); _index++) {
		var _name = _dataStructNames[_index];
		if is_struct(_struct[$ _name]) merge_struct(_struct[$ _name], _dataStruct[$ _name]);
		else if is_array(_struct[$ _name]) {
			for (var _arrayIndex = 0; _arrayIndex < array_length(_struct[$ _name]); _arrayIndex++) {
				if is_struct(_struct[$ _name][_arrayIndex]) merge_struct(_struct[$ _name][_arrayIndex], _dataStruct[$ _name][_arrayIndex]);
			};
		} else _struct[$ _name] = _dataStruct[$ _name];
	};
};
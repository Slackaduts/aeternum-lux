/// @desc Gets the saveable data of all specified objects (and their children) in the room.
/// @param {array<asset.gmobject>} _objectsToSave Objects that we want to save data of
/// @returns {array}
function get_room_data(_objectsToSave) {
	var _roomData = [];
	for (var _currObj = 0; _currObj < array_length(_objectsToSave); _currObj++) {
		var _obj = _objectsToSave[_currObj];
		for (var _currInst = 0; _currInst < instance_number(_obj); _currInst++) {
			var _inst = instance_find(_obj, _currInst);
			_instData = _inst.save();
			_instData ??= false;
			if _instData array_push(_roomData, _instData);
		};
	};
	
	return _roomData;
};



/**
 * Saves the saveable data of the current room to the global roomData struct. Does NOT write to file.
 * @param {array<asset.gmobject>} [_objectsToSave]=[objCombatant, objCamera] Description
 */
function save_room(_objectsToSave = [objCombatant, objCamera]) {
	var _roomData = get_room_data(_objectsToSave);
	global.roomData[$ room_get_name(room)] = _roomData;
};


/**
 * Saves the saveable global data and saveable party data to a global struct. Does NOT write to file.
 */
function save_player() {
	global.saveData = {};
	global.saveData.currRoom = room;
	global.saveData.cameraData = objCamera.save();
	global.saveData.partyObjectNames = array_foreach(global.partyObjects, object_get_name);
	global.saveData.movementStatus = global.movementStatus;
	global.saveData.focusObjectName = object_get_name(global.focusObject);
	global.saveData.partyData = [];
	for (var _index = 0; _index < array_length(global.partyObjects); _index++) {
		array_push(global.saveData.partyData, global.partyObjects[_index].alt_save())		
	};
};



/**
 * Transfers the player to the chosen room.
 * @param {string} _roomName Room to go to, by name
 */
function room_transfer(_roomName) {
	save_room();
	//TRANSITION START
	room_goto(asset_get_index(_roomName));
	load_room();
	load_player_hot();
	//TRANSITION END
};



/**
 * Loads the party and player data, for game start.
 * @param {bool} [_cleanup]=true Whether we should delete globals after using them
 */
function load_player_cold(_cleanup = true) {
	global.partyObjects = array_foreach(global.saveData.partyObjectNames, asset_get_index);
	global.partyObjectNames = global.saveData.partyObjectNames;
	global.movementStatus = global.saveData.movementStatus;
	
	var _cam = instance_create_depth(0, 0, 0, objCamera);
	for (var _index = 0; _index < array_length(variable_struct_get_names(global.saveData.cameraData)); _index++) {
		var _arg = objCamera.dataToSave[_index];
		_cam[$ _arg] = global.saveData.cameraData[$ _arg];
	};

	global.focusObject = asset_get_index(global.saveData.focusObjectName);
	
	for (var _currObj = 0; _currObj < array_length(global.partyObjects); _currObj++) {
		var _obj = global.partyObjects[_currObj];
		with (instance_create_depth(x, y, layer_get_depth("Instances"), _obj)) {
			var _names = variable_struct_get_names(global.saveData.partyData[_currObj]);
			for (var _data = 0; _data < array_length(global.saveData.partyData[_currObj]); _data++) {
				var _currData = _names[_data];
				self[$ _currData] = global.saveData.partyData[_currObj][$ _currData];
			};
		};
	};
	
	if _cleanup delete global.saveData;
};


/**
 * Loads the player, meant for room changes and we already have global player data initialized.
 */
function load_player_hot() {
	global.partyInstances = [];
	for (var _currObj = 0; _currObj < array_length(global.partyObjects); _currObj++) {
		var _obj = global.partyObjects[_currObj];
		array_push(global.partyInstances, instance_create_depth(x, y, layer_get_depth("Instances"), _obj))
		var _names = variable_struct_get_names(global.saveData.partyData[_currObj]);
		for (var _data = 0; _data < array_length(global.saveData.partyData[_currObj]); _data++) {
			var _currData = _names[_data];
			global.partyInstances[_currObj][$ _currData] = global.saveData.partyData[_currObj][$ _currData];
		};
	};
};


/**
 * Loads in saved instances according to the current room.
 * @param {array<asset.gmobject>} [_objectsToSave]=[objCombatant, objCamera] Objects to load data from, same as saving function
 */
function load_room(_objectsToSave = [objCombatant, objCamera]) {
	_layer = layer_get_id("Instances");
	clear_room();
	var _roomData = [];
	var _roomName = room_get_name(room);
	if !variable_struct_exists(global.roomData, _roomName) read_room(_roomName);
	for (var _currObj = 0; _currObj < array_length(_objectsToSave); _currObj++) {
		var _obj = _objectsToSave[_currObj];
		for (var _currInst = 0; _currInst < instance_number(_obj); _currInst++) {
			var _instData = global.roomData[_currInst];
			if _instData != {} {
				var _inst = instance_create_layer(_instData.x, _instData.y, _layer, _obj);
				var _instDataNames = variable_struct_get_names(_instData);
			
				for (var _index = 0; _index < array_length(_instDataNames); _index++) {
					var _currInstName = _instDataNames[_index];
					_inst[$ _currInstName] = _instData[$ _currInstName];
				};
			};
		};
	};
};



/**
 *  Clears the saveable objects in a room, so new ones can be created and overwritten.
 * @param {array<asset.gmobject>} [_objectsToSave]=[objCombatant, objCamera] Objects to clear, should be same as saving function
 */
function clear_room(_objectsToSave = [objCombatant, objCamera]) {
	var _roomData = [];
	for (var _currObj = 0; _currObj < array_length(_objectsToSave); _currObj++) {
		var _obj = _objectsToSave[_currObj];
		for (_currInst = 0; _currInst < instance_number(_obj); _currInst++) {
			var _inst = instance_find(_obj, _currInst);
			instance_destroy(_inst, true);
		};
	};
};


/**
 * Returns a filepath of the save location, and creates it if it doesn't already exist
 * @param {string} [_end]="roomData" String to append to the end of the filepath
 * @returns {string}
 */
function save_path(_end = "roomData") {
	var _path = string_concat("saveData\\", _end);
	if !directory_exists(_path) directory_create(_path);
	
	return _path;	
};



/**
 * Saves the game and writes save data to file(s).
 */
function write_game() {
	save_room();
	show_debug_message(1);
	show_debug_message(global.roomData);
	write_room(room_get_name(room));
	show_debug_message(2);
	save_player();
	show_debug_message(3);
	write_player();
	show_debug_message(4);
};


function load_game() {
	read_player();
	room_goto(global.saveData.currRoom);
	load_room();
	load_player_cold();
};



/**
 * Writes the data of a room to file, by name. This function assumes the room has already been loaded.
 * @param {any*} _roomName Name of the room to save to file.
 * @param {bool} [_cleanup]=true Whether we should delete the loaded roomData after writing to file
 */
function write_room(_roomName, _cleanup = true) {
	var _roomDataDir = save_path();
	
	var _snap = global.roomData[$ _roomName];
	var _filename = string_concat(_roomDataDir, "\\", _roomName, ".yml");
	SnapStringToFile(_snap, _filename);
	if _cleanup delete global.roomData[$ _roomName];
};



function read_player() {
	global.saveData = {};
	var _path = save_path("");
	var _filename = string_concat(_path, "saveData.yml");
	var _snap = SnapStringFromFile(_filename);
	global.saveData = SnapFromYAML(_snap);	
};



/**
 * Writes global/player/party data to file. Assumes this sata is already loaded.
 * @param {bool} [_cleanup]=true Whether we should delete the loaded saveData after writing to file
 */
function write_player(_cleanup = true) {
	var _path = save_path("");
	
	var _snap = global.saveData;
	var _filename = string_concat(_path, "saveData.yml");
	show_debug_message(_filename);
	SnapStringToFile(_snap, _filename);
	if _cleanup delete global.saveData;	
};



/**
 * Loads room data from file into memory. Assumes this saved data actually exiss.
 * @param {any*} _roomName The name of the room to read the saved data of
 */
function read_room(_roomName) {
	var _roomDataDir = save_path();
	
	var _filename = string_concat(_roomDataDir, "\\", _roomName, ".yml");
	var _snap = SnapStringFromFile(_filename);
	global.roomData[$ _roomName] = SnapFromYAML(_snap);
};
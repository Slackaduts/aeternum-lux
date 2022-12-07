
function save_room() {
	var _objectsToSave = [objCombatant, objCamera];
	var _roomData = [];
	for (var _currObj = 0; _currObj < array_length(_objectsToSave); _currObj++) {
		var _obj = _objectsToSave[_currObj];
		for (var _currInst = 0; _currInst < instance_number(_obj); _currInst++) {
			var _inst = instance_find(_obj, _currInst);
			array_push(_roomData, _inst.save());
		};
	};
	
	global.roomData[$ room_get_name(room)] = _roomData;
};


//function save_player() {
	
	
	
//};


function load_room() {
	var _objectsToSave = [objCombatant, objCamera];
	_layer = layer_get_id("Instances");
	clear_room();
	var _roomData = [];
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



function clear_room() {
	var _roomData = [];
	for (var _currObj = 0; _currObj < array_length(objectsToSave); _currObj++) {
		var _obj = objectsToSave[_currObj];
		for (_currInst = 0; _currInst < instance_number(_obj); _currInst++) {
			var _inst = instance_find(_obj, _currInst);
			instance_destroy(_inst, true);
		};
	};
};



function write_room(_roomName, _cleanup = true) {
	var _roomDataDir = "saveData\\roomData";
	if !directory_exists(_roomDataDir) directory_create(_roomDataDir);
	
	var _snap = global.roomData[$ _roomName];
	var _filename = string_concat(_roomDataDir, "\\", _roomName, ".yml");
	SnapStringToFile(_snap, _filename);
	delete global.roomData[$ _roomName];
};



function read_room(_roomName) {
	var _roomDataDir = "saveData\\roomData";
	if !directory_exists(_roomDataDir) exit;
	
	var _filename = string_concat(_roomDataDir, "\\", _roomName, ".yml");
	var _snap = SnapStringFromFile(_filename);
	global.roomData[$ _roomName] = SnapFromYAML(_snap);
};
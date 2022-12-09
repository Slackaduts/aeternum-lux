/// @desc Returns a struct of saveable data from an instance. 
/// @param {Id.Instance} _inst Description
/// @returns {struct}
function get_instance_data(_inst) {
	var _instData = {};
	if variable_instance_exists(_inst, "dataToSave") {
		var _relevantData = _inst.dataToSave;
		_instData.spawnObjName = object_get_name(_inst);
		for (var _index = 0; _index < array_length(_relevantData); _index++) {
			var _name = _relevantData[_index];
			_instData[$ _name] = _inst[$ _name];
		};
	};
	
	return _instData;	
};



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


function temp_save_current_room() {
	global.roomData[$ room_get_name(room)] = [];
	for (var _index = 0; _index < array_length(instance_id); _index++) {
		var _inst = instance_id[_index];
		var _instData = get_instance_data(_inst);
		if _instData != {} array_push(global.roomData[$ room_get_name(room)], _instData);
	};
};


//function write_room() {
	
	
	
//};


//function load_room(_roomName) {
//};
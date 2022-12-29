/// @desc Updates the main ppfx profile in the desired object.
/// @param {asset.GMObject} [_obj]=objCamera Object holding the ppfx manager/profiles. Defaults to the camera object.
function update_main_ppfx(_obj = objCamera) {
	var _inst = instance_find(_obj, 0);
	with (_inst) {
		main_profile = ppfx_profile_create("Main", ppfx_effects.get_array());
		ppfx_profile_load(ppfx_id, main_profile);
	};
};


/**
 * Creates a struct that has data retreived via indexes. Useful for when you need array-like storage but need it to not collapse after data removal.
 */
function indexable_struct() constructor {
	maxIndex = 0
	
	/**
	 * Adds an item to the struct, and returns its index.
	 * @param {any*} _data Data to assign to the lowest available index
	 * @returns {real} Index of the data
	 */
	static add_item = function(_data) {
		for (var _index = 0; _index <= maxIndex; _index++) {
			var _name = string(_index);
			if !variable_struct_exists(self, _name) {
				self[$ _name] = _data;
				return _index;
			};
		};
		
		maxIndex += 1;
		self[$ string(maxIndex)] = _data;
		return maxIndex;
	};
	
	/**
	 * Removes and item from the struct.
	 * @param {any} _index Index of the item to remove
	 */
	static remove_item = function(_index) {
		var _name = string(_index);
		if !variable_struct_exists(self, _name) exit;
		variable_struct_remove(self, _name);
		if _index == maxIndex maxIndex -= 1;
		if maxIndex < 0 maxIndex = 0;
	};
	
	/**
	 * Returns an array of the struct's data. Note that this does not respect empty indexes.
	 * @returns {array}
	 */
	static get_array = function() {
		var _names = variable_struct_get_names(self);
		var _array = [];
		for (var _index = 0; _index < array_length(_names); _index++) {
			if _names[_index] != "maxIndex" array_push(_array, self[$ _names[_index]]);
		};

		return _array;
	};
};

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
	 *  Returns an array of the struct's data. Note that this does not respect empty indexes.
	 * @param {bool} [_numeric_only]=true If we should only consider numbered data entries
	 * @returns {array<Any>} Array of the data in the struct
	 */	
	static get_array = function(_numeric_only = true) {
		var _names = variable_struct_get_names(self);
		var _array = [];
		for (var _index = 0; _index < array_length(_names); _index++) {
			var _name = _names[_index];
			var _numeric = true;
			if _numeric_only _numeric = (_name == string_digits(_name));
			if _name != "maxIndex" && _numeric array_push(_array, self[$ _name]);
		};

		return _array;
	};
};
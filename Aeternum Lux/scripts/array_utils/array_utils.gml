function item_index(_array, _value) {
	for (var currVal = 0; currVal < array_length(_array); currVal++) {
		if _array[currVal] == _value return currVal;
	};
	return undefined;
};


function remove_from_array(_array, _value) {
	var tempArray = [];
	for (var currVal = 0; currVal < array_length(_array); currVal++) {
		if _array[currVal] != _value array_push(tempArray, _array[currVal]);
	};
	return tempArray;
};

/**
 * Adds one struct to another, in place.
 * @param {struct} struct1 The struct we are changing
 * @param {struct} struct2 The struct we are adding to struct1
 */
function add_struct(struct1, struct2) {
	var structNames = variable_struct_get_names(struct2);
	for (var _currEntry = 0; _currEntry < array_length(structNames); _currEntry++) {
		var _currName = structNames[_currEntry];
		if variable_struct_exists(struct1, _currName) struct1[$ _currName] += struct2[$ _currName];
	};
};

/**
 * Subtracts one struct from another, in place.
 * @param {struct} struct1 The struct we are changing
 * @param {struct} struct2 The struct we are subtracting from struct1
 */
function subtract_struct(struct1, struct2) {
	var structNames = variable_struct_get_names(struct2);
	for (var _currEntry = 0; _currEntry < array_length(structNames); _currEntry++) {
		var _currName = structNames[_currEntry];
		if variable_struct_exists(struct1, _currName) struct1[$ _currName] -= struct2[$ _currName];
	};
};



/**
 * Clamps every value in a struct to be within a minimum and maximum value.
 * @param {struct} struct1 Struct to be clamped
 * @param {real} minVal Minimum Value
 * @param {real} maxVal Maximum Value
 */
function clamp_struct(struct1, minVal, maxVal) {
	var structNames = variable_struct_get_names(struct1);
	for (var _currEntry = 0; _currEntry < array_length(structNames); _currEntry++) {
		var _currName = structNames[_currEntry];
		if variable_struct_exists(struct1, _currName) struct1[$ _currName] = clamp(struct1[$ _currName], minVal, maxVal);
	};
};


	
/// @desc Create player light
event_inherited();

inventory = new Inventory();
array_push(dataToSave, "inventory");

alt_save = save;
function save() {};
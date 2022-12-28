function pause(_menuObj = objMainMenu) {
	var _inst = instance_find(_menuObj, 0);
	with (_inst) {
		paused = true;
		instance_deactivate_all(true);
	};
};


function unpause(_menuObj = objMainMenu) {
	var _inst = instance_find(_menuObj, 0);
	with (_inst) {
		instance_activate_all();
		paused = false;
		instance_destroy(yui, true);
		yui = undefined;
	};
};
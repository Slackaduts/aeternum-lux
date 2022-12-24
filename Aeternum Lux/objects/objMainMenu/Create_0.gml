paused = false;
yui = undefined;
saved = false;


function pause() {
	yui = create_yui_obj("\\YUI\\Screens\\mainmenu.yui", other);
	paused = true;
	instance_deactivate_all(true);
};


function unpause() {
	instance_activate_all();
	paused = false;
	instance_destroy(yui, true);
	yui = undefined;
};

mainMenuData = {
	categories: [
		{name: "Return to Game", call: unpause},
		{name: "Save/Load", call: function() {}},//SAVE MENU CODE
		{name: "Options", call: function() {}}, //OPTIONS MENU CODE
	],
	
	
	
	
};
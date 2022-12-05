enum itemTypes {
	CONSUMABLE,
	REAGENT,
	EQUIPMENT,
	ARTIFACT,
	LAST	
};

enum equipmentTypes {
	HEAD,
	BODY,
	FEET,
	WEAPON,
	ACCESSORY,
	KEEPSAKE,
	LAST
};



/**
 * Creates a new inventory struct.
 */
function Inventory() constructor {
	categories = [{}, {}, {}, {}];

	/**
	 * Checks if an item exists in this inventory object.
	 * @param {struct.Item} _item Item to check if exists
	 * @param {real} [_amount] Specific amount to check for
	 * @returns {bool} Whether the item exists or not
	 */
	static item_exists = function(_item, _amount = undefined) {
		var _exists = variable_struct_exists(categories[_item.itemType], _item.name);
		
		if _exists && _amount != undefined {
			if categories[_item.itemType][$ _item.name].amount < _amount _exists = false;
		};
		
		return _exists;
	};
	
	
	/**
	 * Returns a single category of items as an array of items.
	 * @param {real} _category The item category to return
	 * @param {bool} [_alphabetize]=true  Whether the item array should be alphabetized
	 * @returns {array}
	 */	
	static get_category_inventory_array = function(_category, _alphabetize = true) {	
		var _categoryNames = variable_struct_get_names(categories[_category])
		var _items = [];
		for (var _currItem = 0; _currItem < array_length(_categoryNames); _currItem++) {
			var _item = categories[_category][$ _categoryNames[_currItem]];
			//show_debug_message(_item);
			array_push(_items, _item);
		};
		
		//Alphabetize, by case lowered item name
		if _alphabetize array_sort(_items, function(left, right) {
		    if (left.name < right.name)
		        return -1;
		    else if (string_lower(left.name) > string_lower(right.name))
		        return 1;
		    else
		        return 0;
		});

		return _items;
	};


	/**
	 * Returns the number of total items in a category, using their amounts.
	 * @param {real} _category Category to check
	 * @returns {real} Number of items in that category
	 */
	static category_total_items = function(_category) {	
		var _categoryNames = variable_struct_get_names(categories[_category])
		var _totalItems = 0;
		for (var _currItem = 0; _currItem < array_length(_categoryNames); _currItem++) {
			var _item = categories[_category][$ _categoryNames[_currItem]];
			_totalItems += categories[_item.itemType][$ _item.name].amount;
		};
		return _totalItems;
	};


	/**
	 * Returns the total items of the inventory.
	 * @returns {real} Number of total inventory items
	 */
	static total_items = function() {
		var _totalItems = 0;
		for (var _currCat = 0; _currCat < array_length(categories); _currCat++) {
			_totalItems += category_total_items(_currCat);
		};
		return _totalItems;
	};


	/**
	 * Adds an item to the inventory.
	 * @param {struct.Item} _item Item to add to the inventory
	 * @param {real} [_amount] Optional amount to add
	 */
	static add_item = function(_item, _amount = undefined) {
		_amount ??= 1;
		if item_exists(_item) categories[_item.itemType][$ _item.name].amount += _amount
		else {
			categories[_item.itemType][$ _item.name] = _item;
			categories[_item.itemType][$ _item.name].amount = _amount;
			
		};
		show_debug_message(categories[_item.itemType][$ _item.name])
	};
	
	
	//static give_item = function(_item) {
	//	if item_exists(_item) categories[_item.itemType][$ _item.name].amount += _item.amount
	//	else categories[_item.itemType][$ _item.name] = _item;
	//};


	/**
	 * Removes an item from the inventory.
	 * @param {struct.Item} _item Item to remove from the inventory
	 * @param {real} [_amount] Optional amount to remove
	 */
	static remove_item = function(_item, _amount = undefined) {
		if _amount != undefined _item.amount = _amount;
		if item_exists(_item) {
			if _item.amount >= categories[_item.itemType][$ _item.name].amount delete categories[_item.itemType][$ _item.name]
			else categories[_item.itemType][$ _item.name].amount -= _item.amount;
		};
	};
};



/**
 * Gets the alphabetized item array of a given inventory category.
 * @param {real} _category Category to pick from, refer to the enum
 */
function gui_get_inventory_cat(_category) {
	//var _obj = undefined;
	//if global.focusInstance.inventory.total_items() == 0 _obj = objCamera;
	//else _obj = global.focusInstance;
	var _inst = instance_nearest(0, 0, objCamera);
	return _inst.inventory.get_category_inventory_array(_category);
};



/**
 * A struct containing data about icons.
 * @param {string} _sprite Sprite name of the icon sheet
 * @param {real} [_frame]=1 Image index of the desired icon of the specified sheet
 */
function Icon(_sprite, _frame = 1) constructor {
	//sprite = asset_get_index(_sprite);
	sprite = _sprite;
	frame = _frame;	
};



/**
 * Creates a new consumable Item struct. Interops with inventory struct/system
 * @param {string} _name Name of the item
 * @param {string} _desc Item description
 * @param {struct.Icon} _icon Icon data for the item
 * @param {array} [_recipe]=[] Recipe data for the item
 * @param {struct.CombatStats} [_statsMod]=new CombatStats() Optional stats for the item
 */
function Item(_name, _desc, _icon, _recipe = [], _statsMod = new CombatStats()) constructor {
	name = _name;
	itemType = itemTypes.CONSUMABLE;
	desc = _desc;
	icon = _icon;
	stats = new CombatStats();
	stats.setStats(_statsMod);
	amount = 1;
	recipe = _recipe;


	/**
	 * Uses the item. Applies stats then removes self.
	 * @param {asset.gmobject} [_obj]=objCamera Object to remove from the inventory of 
	 */
	static use = function(_obj = objCamera) {
		global.focusInstance.combatant.liveStats.applyStats(stats);
		if global.focusInstance.inventory.total_items() == 0 _obj.inventory.remove_item(self, 1);
		else global.focusInstance.inventory.remove_item(self, 1);
	};


	/**
	 * Crafts an item. Deletes all recipe items and in their amounts, then creates the product item.
	 * @param {asset.gmobject} [_obj]=objCamera Object to use the inventory of 
	 */
	static craft = function(_obj = objCamera) {
		//Handle local inventories
		if global.focusInstance.inventory.total_items() != 0 _obj = global.focusInstance;

		//Check if we have all ingredients in our inventory and in the proper amounts
		var _canCraft = true;
		for (var _currItemData = 0; _currItemData < array_length(recipe); _currItemData++) {
			var _recipeItem = recipe[_currItemData];
			if !_obj.inventory.item_exists(_recipeItem.name, _recipeItem.amount) {
				_canCraft = false;
				break;
			};
		};
		//Remove recipe items and give us the desired item
		if _canCraft {
			for (var _currItemData = 0; _currItemData < array_length(recipe); _currItemData++) {
				var _recipeItem = recipe[_currItemData];
				_obj.inventory.remove_item(get_item(_recipeItem.name), _recipeItem.amount);

			_obj.inventory.add_item(self, 1);
			};
		};
	};
};




/**
 * Creates a new Reagent item. These are used purely for crafting and serve zero functional purpose.
 * @param {string} _name Name of the item
 * @param {string} _desc Item description
 * @param {struct.Icon} _icon Item icon data (struct containing sprite and image index)
 * @param {array} [_recipe]=[] Recipe data, array of structs containting item name and amounts
 */
function Reagent(_name, _desc, _icon, _recipe = []) : Item(_name, _desc, _icon, _recipe) constructor {
	itemType = itemTypes.REAGENT;
	static use = function() {};
};



 /**
  * Creates a new equipment item.
  * @param {string} _name Name of the equipment
  * @param {string} _desc Equipment description
  * @param {struct.Icon} _icon Sprite icon for this equipment
  * @param {struct.CombatStats} _statsMod Stats of the equipment item
  * @param {array} [_recipe]=[] Recipe data for this item
  * @param {real} [_equipmentType]=equipmentTypes.BODY Equipment type, see equipmentTypes enum
  * @param {string} [_nameReq] Combatant name required for equipping. Useful for class locking.
  * @param {real} [_levelReq]=0 Level requirement to equip
  */
 function Equipment(_name, _desc, _icon, _statsMod, _recipe = [], _equipmentType = equipmentTypes.BODY, _nameReq = undefined, _levelReq = 0) : Item(_name, _desc, _icon, _recipe, _statsMod) constructor {
	itemType = itemTypes.EQUIPMENT;
	equipmentType = equipmentTypes.BODY;
	levelReq = _levelReq;
	nameReq = _nameReq;
	equipped = false;
	stats.setStats(_statsMod);
	recipe = _recipe;
	
	static use = function() {};


	static equip = function() {
		//TODO: CHECK FOR IF WE ACTUALLY CAN EQUIP AN ITEM
		global.focusInstance.combatant.baseStats.applyStats(stats);
	};


	static unequip = function() {
		global.focusInstance.combatant.baseStats.revokeStats(stats);	
	};
};



function KeyItem(_name, _desc, _icon, _recipe = [], _scenes = [[]]) : Item(_name, _desc, _icon, _recipe) constructor {
	type = itemTypes.ARTIFACT;
	sceneManager = new scene_manager(_scenes);

	static use = function() {
		//PUSH TO SCENE POOL OF INSTANCE
	};
};



/**
 * Preloads the items database.
 */
function preload_items() {
	global.itemsDatabase = [];
	categoriesToLoad = ["items", "reagents", "equipment", "keyitems"];
	for (var _cat = 0; _cat < array_length(categoriesToLoad); _cat++) {
		var _file = string_from_file("ItemData/" + categoriesToLoad[_cat] + ".yml");
		array_push(global.itemsDatabase, snap_from_yaml(_file));
	};

	for (var _ref = 0; _ref < array_length(global.itemsDatabase); _ref++) {	
		for (var _item = 0; _item < array_length(global.itemsDatabase[_ref].items); _item++) {
			var _currItem = global.itemsDatabase[_ref].items[_item];
			global.itemsReference[_ref][$ _currItem.name] = _item;
		};
	};
};



/**
 * Converts an equipment type string to equipment type enum value.
 * @param {string} _type Equipment type name
 * @returns {real}
 */
function equipment_type(_type) {
	switch string_lower(_type) {	
		case "head":
			return equipmentTypes.HEAD;
		break;
		case "body":
			return equipmentTypes.BODY;
		break;
		case "feet":
			return equipmentTypes.FEET;
		break;
		case "weapon":
			return equipmentTypes.WEAPON;
		break;
		case "accessory":
			return equipmentTypes.ACCESSORY;
		break;
		case "keepsake":
			return equipmentTypes.KEEPSAKE;
		break;
		default:
			return undefined;
	};	
};


/**
 * Returns an item object by name after the items database has been preloaded.
 * @param {string} _name Name of the item
 * @param {real} [_amount]=1 Amount of the item
 */
function get_item(_name, _amount = 1) {
	var _item = undefined;
	_amount ??= 0;
	for (var _currStruct = 0; _currStruct < array_length(global.itemsReference); _currStruct++) {
		// Search every item type reference, and every item within that reference
		var _struct = global.itemsReference[_currStruct];

		//If the reference has our desired name, we know it is correct
		if variable_struct_exists(_struct, _name) {
			var _itemData = global.itemsDatabase[_currStruct].items[_struct[$ _name]];

			//Defaults if not provided
			if !variable_struct_exists(_itemData, "icon") _itemData.icon = new Icon("sprBaseIcons", 1);
			if !variable_struct_exists(_itemData, "stats") _itemData.stats = new CombatStats();
			if !variable_struct_exists(_itemData, "desc") _itemData.desc = "Nothing is known about this item.";
			if !variable_struct_exists(_itemData, "recipe") _itemData.recipe = [];

			//Handle item-type specific structs
			switch (_currStruct) {
				case itemTypes.CONSUMABLE:
					_item = new Item(_itemData.name, _itemData.desc, _itemData.icon, _itemData.recipe, _itemData.stats);
				break;

				case itemTypes.REAGENT:
					_item = new Reagent(_itemData.name, _itemData.desc, _itemData.icon, _itemData.recipe);
				break;

				case itemTypes.EQUIPMENT:
					if !variable_struct_exists(_itemData, "nameReq") _itemData.nameReq = undefined;
					if !variable_struct_exists(_itemData, "levelReq") _itemData.levelReq = undefined;
					_item = new Equipment(_itemData.name, _itemData.desc, _itemData.icon, _itemData.recipe, _itemData.stats, equipment_type(_itemData.equipmentType), _itemData.nameReq, _itemData.levelReq);
				break;

				case itemTypes.ARTIFACT:
					_item = new KeyItem(_itemData.name, _itemData.desc, _itemData.icon, _itemData.stats) // IMPLEMENT SCENES FROM FILE SOMEHOW
				break;
			};
		};
	_item.amount += _amount;
	return _item;
	};
};


/**
 * Creates a string for showing amounts in a GUI. Workaround for incomplete string concat implementation in YUI.
 * @param {any} _amount Number to show as an amount
 * @returns {string} The gui-ready amount string
 */
function gui_amount_view(_amount) {
	return string_concat("x", string(_amount))
};
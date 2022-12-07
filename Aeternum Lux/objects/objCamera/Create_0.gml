/// @desc Initialize camera
global.focusObject = objNero;
global.focusInstance = instance_nearest(x, y, objNero);

global.collisionLayers = [];
global.collisionTileSets = [];
global.maxObjectDepth = 0;
global.minObjectDepth = 0;
global.movementStatus = true;

focusIndex = 0;
global.partyObjects = [objNero, objRena, objAurra, objGaro];
global.partyInstances = [];
global.followerObjects = [];

viewWidth = 1280;
viewHeight = 720;

windowScale = 1;

camX = x;
camY = y;
global.cameraSpeed = 0.15;


keyRotate = 0;
canRotate = true;

display_reset(display_aa, true);
display_set_timing_method(tm_countvsyncs);
window_set_size(viewWidth * windowScale, viewHeight * windowScale);
alarm[0] = 500;
//alarm_set(0, 500);

//TODO: Implement KeyItems
global.itemsDatabase = [];
global.itemsReference = [{}, {}, {}, {}];
preload_items();

inventory = new Inventory();
inventory.add_item(get_item("Basic Potion"), 63);
inventory.add_item(get_item("Basic Ether"), 2);
inventory.add_item(get_item("Alchemist's Brew"), 1);
inventory.add_item(get_item("Wild Mushroom"), 7);
inventory.add_item(get_item("Field Cricket"), 4);
test = inventory.get_category_inventory_array(0);
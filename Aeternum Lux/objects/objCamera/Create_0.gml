/// @desc Initialize camera
global.focusObject = objNero;

global.collisionLayers = [];
global.collisionTileSets = [];
global.maxObjectDepth = 0;
global.minObjectDepth = 0;
global.movementStatus = true;

focusIndex = 0;
global.partyObjects = [objNero, objRena, objAurra, objGaro];

viewWidth = 1280;
viewHeight = 720;

windowScale = 1;

camX = x;
camY = y;
global.cameraSpeed = 0.15;


keyRotate = 0;
canRotate = true;

display_reset(display_aa, true);
show_debug_overlay(true);
display_set_timing_method(tm_countvsyncs);
window_set_size(viewWidth * windowScale, viewHeight * windowScale);
alarm[0] = 500;

//PPFX Initialization
ppfx_application_render_init();
ppfx_id = ppfx_create();
ppfx_effects = new indexable_struct();
var _i = ppfx_effects.add_item(new pp_bloom(true, 5, 0.4, 1.12)); //permanent bloom effect, looks really good on fires
main_profile = ppfx_profile_create("Main", ppfx_effects.get_array());
show_debug_message(main_profile);
ppfx_profile_load(ppfx_id, main_profile);

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

dataToSave = [
"inventory",
"camX",
"camY",
"viewWidth",
"viewHeight",
"windowScale",
"focusIndex"
];
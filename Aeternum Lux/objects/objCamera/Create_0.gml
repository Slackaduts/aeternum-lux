/// @desc Initialize camera
global.focusObject = objNero;

global.maxObjectDepth = 0;
global.minObjectDepth = 0;
global.movementStatus = true;

focusIndex = 0;
global.partyObjects = [objNero, objRena, objAurra, objGaro];
viewWidth = 640;
viewHeight = 360;

windowScale = 4;
zoomFactor = 0.5;

camX = round(x);
camY = round(y);
isMoving = true;
pastCamX = camX;
pastCamY = camY;
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
_i = ppfx_effects.add_item(new pp_shockwaves(true, 0.1, 0.1, sprite_get_texture(__spr_ppf_prism_lut_rb, 0))); //permanent shockwave effect so shockwaves can happen at any time
main_profile = ppfx_profile_create("Main", ppfx_effects.get_array());
ppfx_profile_load(ppfx_id, main_profile);

// init shockwaves distortion surface
shockwaves_sys_id = shockwave_create();

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

//IMPORTANT: Makes spatial audio work and not have flipped channels
audio_listener_orientation(0,1,0,0,0,1);
global.sounds = new indexable_struct(); //

//global.pathfindGrid = undefined;
//baseGrid = undefined;
//culling = call_later(15, time_source_units_frames, cull_instances, true);

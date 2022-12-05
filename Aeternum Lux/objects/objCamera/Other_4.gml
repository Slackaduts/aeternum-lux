/// @desc Enable View
view_enabled = true;
view_visible[0] = true;

global.collisionLayers = [];
global.collisionTileSets = [];
var layers = layer_get_all();

global.maxObjectDepth = layer_get_depth("Instances") + 100;
global.minObjectDepth = global.maxObjectDepth - 200;

for (var currLayer = 0; currLayer < array_length(layers); currLayer++) {
	var layerName = layer_get_name(layers[currLayer]);
	if (string_count("tile", string_lower(layerName)) > 0) {
		var currTileMap = layer_tilemap_get_id(layers[currLayer]);
		var currTileSet = tilemap_get_tileset(currTileMap);
		var currTileSetName = tileset_get_name(currTileSet);
		
		array_push(global.collisionLayers, layers[currLayer]);
		array_push(global.collisionTileSets, string_replace(currTileSetName, "ts", "obj"));
	};
	
};

global.focusInstance = instance_nearest(x, y, objNero);
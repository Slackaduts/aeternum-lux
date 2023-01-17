/// @desc Enable view, setup collisions and pathfinding
view_enabled = true;
view_visible[0] = true;

var layers = layer_get_all();

global.maxObjectDepth = layer_get_depth("Instances") + 100;
global.minObjectDepth = global.maxObjectDepth - 200;


for (var currLayer = 0; currLayer < array_length(layers); currLayer++) {
	var layerName = layer_get_name(layers[currLayer]);
	if (string_count("tile", string_lower(layerName)) > 0) {
	    var tile_guide = layer_tilemap_get_id(layers[currLayer]);
		var _tileSet = tilemap_get_tileset(tile_guide);
		var _tileSetName = string_replace(tileset_get_name(_tileSet), "ts", "spr");
		var _sprite = asset_get_index(_tileSetName + "ColFrames");
		var _tileHeight = tilemap_get_tile_height(tile_guide);
		var _tileWidth = tilemap_get_tile_height(tile_guide);

	    for (var i = 0; i < tilemap_get_width(tile_guide); i++;) //Horizontal
	        {
	        for (var j = 0; j < tilemap_get_height(tile_guide); j++;) //Vertical
	            {
					var data = tilemap_get(tile_guide, i, j); //Get tile info
					instance_create_layer(i * _tileWidth, j * _tileHeight, "Instances", objTile, {sprite_index: _sprite, image_index: data, image_speed: 0, tileWidth: _tileWidth, tileHeight: _tileHeight});
	            };
	        };
	};
};


//global.pathfindGrid = mp_grid_create(0, 0, room_width / 32, room_height / 32, 32, 32);

//mp_grid_add_instances(global.pathfindGrid, objTile, true);
/// @desc PPFX
// Get exact position and size of original application_surface
var _pos = application_get_position();
var _view_width = surface_get_width(application_surface), _view_height = surface_get_height(application_surface);

// Draw post-processing on screen
ppfx_draw(application_surface, _pos[0], _pos[1], _pos[2]-_pos[0], _pos[3]-_pos[1], _view_width, _view_height, ppfx_id);

/*-------------------------------------------------------------------------------------------------
	These functions are independent, so if you delete them from the asset, nothing will happen.
-------------------------------------------------------------------------------------------------*/

//enum PP_DEBUG_TYPE {
//	STACK_SURFACES,
//	CHANNELS_HISTOGRAM,
//}

/*
// ------- WORK IN PROGRESS (don't use it yet) -------
/// @desc Draw post-processing system debug information on screen
/// @param {real} x1 Horizontal X position of debug view.
/// @param {real} y1 Vertical Y position of debug view.
/// @param {real} x2 Width of the debug view.
/// @param {real} y2 Height of the debug view.
/// @param {struct} pp_index The returned variable by ppfx_create()
/// @param {real} debug_type Debug view index
/// @returns {undefined}
function ppfx_debug_draw(x1, y1, x2, y2, pp_index, debug_type) {
	with(pp_index) {
		var _view_width = x2 - x1;
		var _view_height = y2 - y1;
		
		// draw debug visualizations
		switch(debug_type) {
			case PP_DEBUG_TYPE.STACK_SURFACES:
				draw_set_color(c_black);
				draw_rectangle(x1, y1, x2, y2, false);
				draw_set_color(c_white);
				
				var _surf = -1;
				var _xx, _yy;
				var _cellw = (_view_width/3), _cellh = (_view_height/3);
				//var _rows = ceil((_view_width - _cellw) / _cellw);
				
				var j = 0, jsize = __surf_index;
				repeat(jsize) {
					_xx = j mod 3;
					_yy = j div 3;
					_surf = __stack_surface[j];
					if surface_exists(_surf) {
						var _xxx = x1+(_xx*_cellw);
						var _yyy = y1+(_yy*_cellh);
						draw_surface_stretched(_surf, _xxx, _yyy, _cellw, _cellh);
					}
					j++;
				}
				break;
			
			case PP_DEBUG_TYPE.CHANNELS_HISTOGRAM:
				draw_set_color(c_white);
				shader_set(__ppf_sh_histogram);
				texture_set_stage(shader_get_sampler_index(__ppf_sh_histogram, "data_tex"), surface_get_texture(__stack_surface[__surf_index]));
				draw_sprite_stretched_ext(__spr_ppf_pixel, 0, x1, y1, _view_width, _view_height, c_black, 1);
				shader_reset();
				break;
				
			default:
				draw_set_color(make_color_rgb(20, 20, 20));
				draw_rectangle(x1, y1, x2, y2, false);
				draw_set_color(c_white);
				draw_rectangle(x1+2, y1+2, x2-2, y2-2, true);
				draw_sprite(__spr_ppf_debug_icon, 0, x1+_view_width/2, y1+_view_height/2);
				break;
		}
		draw_set_color(c_white);
	}
}
*/

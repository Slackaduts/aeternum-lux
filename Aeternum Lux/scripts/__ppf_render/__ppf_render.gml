
global.__ppf_aplication_render_enabled = true;
/// @desc This function disables the default drawing of application_surface.
function ppfx_application_render_init() {
	global.__ppf_aplication_render_enabled = false;
	application_surface_draw_enable(global.__ppf_aplication_render_enabled);
}


/// @desc This function enables the default drawing of application_surface.
function ppfx_application_render_free() {
	global.__ppf_aplication_render_enabled = true;
	application_surface_draw_enable(global.__ppf_aplication_render_enabled);
}

/// @desc Toggle whether or not to enable the default drawing of application_surface.
/// @param {real} enabled Will be either true (enabled, the default value) or false (disabled). The drawing will toggle if nothing or -1 is entered.
function ppfx_application_render_set_enable(enabled=-1) {
	if (enabled != -1) {
		global.__ppf_aplication_render_enabled = enabled;
	} else {
		global.__ppf_aplication_render_enabled ^= 1;
		application_surface_draw_enable(global.__ppf_aplication_render_enabled);
	}
}

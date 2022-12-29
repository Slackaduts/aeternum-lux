
/*-------------------------------------------------------------------------------------------------
	These functions are independent, so if you delete them from the asset, nothing will happen.
-------------------------------------------------------------------------------------------------*/

/// @ignore
function __ppfx_layer() constructor {
	__room_size_based = false;
	__top_layer = -1;
	__bottom_layer = -1;
	__top_method = -1;
	__bottom_method = -1;
	__ppf_index = undefined;
	__cam_index = -1;
	__surf = -1;
	__surf_x = 0;
	__surf_y = 0;
	__surf_w = 2;
	__surf_h = 2;
	__surf_vw = 0;
	__surf_vh = 0;
	__is_render_enabled = true;
	__use_ppfx = true;
	__is_ready = false;
}

/// @desc Create post-processing layer id to be used by the other functions
/// @returns {Struct}
function ppfx_layer_create() {
	return new __ppfx_layer();
}

/// @desc Checks if a previously created post-processing layer exists.
/// @param {any} pp_layer_index description
/// @returns {bool} description
function ppfx_layer_exists(pp_layer_index) {
	return (is_struct(pp_layer_index) && instanceof(pp_layer_index) == "__ppfx_layer");
}

/// @desc This function deletes a previously created post-processing layer, freeing memory.
/// @param {Struct} pp_layer_index The returned variable by ppfx_layer_create()
/// @returns {undefined}
function ppfx_layer_destroy(pp_layer_index) {
	__ppf_exception(!ppfx_layer_exists(pp_layer_index), "Post-processing layer does not exist.");
	__ppf_surface_delete(pp_layer_index.__surf);
	delete pp_layer_index;
}

/// @desc This function applies post-processing to one or more layers. You only need to call this ONCE in an object's Create Event.
/// Make sure the top layer is above the bottom layer in order. If not, it may not render correctly.
/// Please note: You CANNOT select a range to which the layer has already been in range by another system. This will give an unbalanced surface stack error. If you want to use more effects, just add more effects to the profile.
/// @param {Struct} pp_index The returned variable by ppfx_create(). You can use -1, noone or undefined, to not use a post-processing system, this way you can render the layer content on the surface only.
/// @param {Struct} pp_layer_index The returned variable by ppfx_layer_create()
/// @param {Id.Layer} top_layer_id The top layer, in the room editor
/// @param {Id.Layer} bottom_layer_id The bottom layer, in the room editor
/// While off, uses camera position and size.
/// @param {bool} draw_layer If false, the layer will not draw and the layer content will still be rendered to the surface.
/// @returns {undefined}
function ppfx_layer_apply(pp_index, pp_layer_index, top_layer_id, bottom_layer_id, draw_layer=true) {
	__ppf_exception(!ppfx_layer_exists(pp_layer_index), "Post-processing layer does not exist.");
	__ppf_exception(!layer_exists(top_layer_id) || !layer_exists(bottom_layer_id), "One of the layers does not exist in the current room.");
	if (layer_get_depth(top_layer_id) > layer_get_depth(bottom_layer_id)) {
		__ppf_trace("WARNING: Inverted layer range order. Failed to render on layers: " + layer_get_name(top_layer_id) + ", " + layer_get_name(bottom_layer_id));
	}
	with(pp_layer_index) {
		// run once
		__use_ppfx = !__ppf_is_undefined(pp_index);
		//__ppf_exception(__use_ppfx && !ppfx_exists(pp_index), "Post-processing system does not exist.");
		if (__use_ppfx) ppfx_set_draw_enable(pp_index, draw_layer);
		__top_layer = top_layer_id;
		__bottom_layer = bottom_layer_id;
		__ppf_index = pp_index;
		// run every step
		__top_method = function() {
			if (!__is_render_enabled) exit;
			if (event_type == ev_draw && event_number == 0) {
				__cam_index = view_camera[view_current];
				__surf_x = camera_get_view_x(__cam_index);
				__surf_y = camera_get_view_y(__cam_index);
				__surf_w = camera_get_view_width(__cam_index);
				__surf_h = camera_get_view_height(__cam_index);
				__surf_vw = view_get_wport(view_current);
				__surf_vh = view_get_hport(view_current);
				if !surface_exists(__surf) __surf = surface_create(__surf_vw, __surf_vh);
				surface_set_target(__surf);
				draw_clear_alpha(c_black, 0);
				//gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
				camera_apply(__cam_index);
			}
		}
		__bottom_method = function() {
			if (!__is_render_enabled) exit;
			if (event_type == ev_draw && event_number == 0) {
				if (surface_exists(__surf)) {
					//gpu_set_blendmode(bm_normal);
					surface_reset_target();
					if (__use_ppfx) ppfx_draw(__surf, __surf_x, __surf_y, __surf_w, __surf_h, __surf_vw, __surf_vh, __ppf_index);
					__is_ready = true;
				}
			}
		}
		layer_script_begin(__bottom_layer, __top_method);
		layer_script_end(__top_layer, __bottom_method);
	}
}

/// @desc This function gets the surface used in the PPFX layer system.
/// @param {Struct} pp_layer_index The returned variable by ppfx_layer_create().
/// @param {Bool} with_effects If true, it will return the surface of the layer with the effects applied. False is without the effects.
/// @returns {Id.Surface} Surface index.
function ppfx_layer_get_surface(pp_layer_index, with_effects=true) {
	__ppf_exception(!ppfx_layer_exists(pp_layer_index), "Post-processing layer does not exist.");
	return with_effects ? ppfx_get_render_surface(pp_layer_index.__ppf_index) : pp_layer_index.__surf;
}

/// @desc Toggle whether layer system can render on layer.
/// If disabled, nothing will be rendered to the surface. That is, the layer will be drawn without the effects.
/// @param {Struct} pp_layer_index The returned variable by ppfx_layer_create().
/// @param {real} enable Will be either true (enabled, the default value) or false (disabled). The rendering will toggle if nothing or -1 is entered.
/// @returns {undefined}
function ppfx_layer_set_render_enable(pp_layer_index, enable=-1) {
	__ppf_exception(!ppfx_layer_exists(pp_layer_index), "Post-processing layer does not exist.");
	if (enable == -1) {
		pp_layer_index.__is_render_enabled ^= 1;
	} else {
		pp_layer_index.__is_render_enabled = enable;
	}
}

/// @desc This function checks if the post-processing layer is ready to render, which allows you to get its surface safely (especially in HTML5).
/// @param {Struct} pp_layer_index The returned variable by ppfx_layer_create().
/// @returns {undefined}
function ppfx_layer_is_ready(pp_layer_index) {
	return pp_layer_index.__is_ready;
}

/// @desc This function defines a new range of layers from an existing ppfx layer system.
/// Make sure the top layer is above the bottom layer in order. If not, it may not render correctly.
/// Please note: You CANNOT select a range to which the layer has already been in range by another system. This will give an unbalanced surface stack error. If you want to use more effects, just add more effects to the profile.
/// @param {Struct} pp_layer_index The returned variable by ppfx_layer_create()
/// @param {Id.Layer} top_layer_id The top layer, in the room editor
/// @param {Id.Layer} bottom_layer_id The bottom layer, in the room editor
function ppfx_layer_set_range(pp_layer_index, top_layer_id, bottom_layer_id) {
	__ppf_exception(!ppfx_layer_exists(pp_layer_index), "Post-processing layer does not exist.");
	__ppf_exception(!layer_exists(top_layer_id) || !layer_exists(bottom_layer_id), "One of the layers does not exist in the current room.");
	if (layer_get_depth(top_layer_id) > layer_get_depth(bottom_layer_id)) {
		__ppf_trace("WARNING: Inverted layer range order. Failed to render on layers: " + layer_get_name(top_layer_id) + ", " + layer_get_name(bottom_layer_id));
	}
	with(pp_layer_index) {
		__ppf_surface_delete(__surf);
		layer_script_begin(__bottom_layer, -1);
		layer_script_end(__top_layer, -1);
		__top_layer = top_layer_id;
		__bottom_layer = bottom_layer_id;
		layer_script_begin(__bottom_layer, __top_method);
		layer_script_end(__top_layer, __bottom_method);
	}
}

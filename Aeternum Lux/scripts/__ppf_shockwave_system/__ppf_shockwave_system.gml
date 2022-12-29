
/*-------------------------------------------------------------------------------------------------
	These functions are independent, so if you delete them from the asset, it will not interfere
	with other features of PPFX.
-------------------------------------------------------------------------------------------------*/

/// @ignore
function __shockwave_system() constructor {
	__surf = -1;
}

/// @desc Create shockwave system id to be used by the other functions.
/// @returns {Struct} Shockwave system id.
function shockwave_create() {
	__ppf_trace("Shockwave system created. From: " + object_get_name(object_index));
	return new __shockwave_system();
}

/// @desc Check if shockwave system exists
/// @param {Struct} system_index The returned variable by shockwave_create().
/// @returns {Bool}
function shockwave_exists(system_index) {
	return (is_struct(system_index) && instanceof(system_index) == "__shockwave_system");
}

/// @desc Destroy shockwave system, freeing it from memory.
/// @param {Struct} system_index The returned variable by shockwave_create().
function shockwave_free(system_index) {
	__ppf_exception(!shockwave_exists(system_index), "Shockwaves system does not exist.");
	__ppf_surface_delete(system_index.__surf);
}

/// @desc Renderize shockwave surface. Please note that this will not draw the surface, only generate the content.
/// Basically this function will call the Draw Event of the objects in the array and draw them on the surface.
/// This surface will be sent to the post-processing system automatically.
/// @param {Struct} pp_index The returned variable by ppfx_create().
/// @param {Struct} system_index The returned variable by shockwave_create().
/// @param {Array<Asset.GMObject>} objects_array Distortion objects array that will be used to call the Draw Event. Example: [obj_shockwave].
/// @param {Id.Camera} camera Your current active camera id. You can use view_camera[0].
function shockwave_render(pp_index, system_index, objects_array, camera) {
	__ppf_exception(!ppfx_exists(pp_index), "Post-processing system does not exist.");
	__ppf_exception(!shockwave_exists(system_index), "Shockwaves system does not exist.");
	with(system_index) {
		var _cam = camera;
		var _camw = camera_get_view_width(_cam);
		var _camh = camera_get_view_height(_cam);
		var _sx = pp_index.__render_vw/_camw, _sy = pp_index.__render_vh/_camh;
		var _ww = _camw*_sx, _hh = _camh*_sy;
		// generate distortion surface
		if (_ww > 0 && _hh > 0) {
			var _old_blendmode = gpu_get_blendmode();
			var _old_texfilter = gpu_get_tex_filter();
			gpu_set_tex_filter(true);
			if !surface_exists(__surf) {
				__surf = surface_create(_ww, _hh);
				// send "normal map" texture to ppfx (you only need to reference it once - when the surface is created, for example)
				ppfx_effect_set_parameter(pp_index, PP_EFFECT.SHOCKWAVES, PP_SHOCKWAVES_TEXTURE, surface_get_texture(__surf));
			}
			surface_set_target(__surf);
			draw_clear(make_color_rgb(128, 128, 255));
			gpu_set_blendmode_ext(bm_dest_color, bm_src_color);
			camera_apply(_cam);
			shader_set(__PPF_SH_BLEND_NORMALS);
			// draw normal map sprites to distort screen
			var i = 0, isize = array_length(objects_array);
			repeat(isize) {
				with(objects_array[i]) event_perform(ev_draw, 0);
				++i;
			}
			shader_reset();
			gpu_set_blendmode(_old_blendmode);
			gpu_set_tex_filter(_old_texfilter);
			surface_reset_target();
		}
	}
}

/// @desc Create a new shockwave instance.
/// @param {Real} x The horizontal X position the object will be created at.
/// @param {Real} y The vertical Y position the object will be created at.
/// @param {String|Id.Layer} layer_id The layer ID (or name) to assign the created instance to.
/// @param {Real} index The shockwave shape (image_index).
/// @param {Real} scale The shockwave size (default: 1).
/// @param {Real} speedd The shockwave speed

/// @param {Asset.GMObject} object The object to be created.
/// @returns {Id.Instance} Instance id.
function shockwave_instance_create(x, y, layer_id, index=0, scale=1, speedd=0.01, object=__obj_ppf_shockwave, curve=__ac_ppf_shockwave) {
	if (os_browser == browser_not_a_browser) {
		var _inst = instance_create_layer(x, y, layer_id, object, {
			visible : false,
			index : index,
			scale : scale,
			spd : speedd,
			curve : curve
		});
		return _inst;
	} else {
		var _inst = instance_create_layer(x, y, layer_id, object); 
		_inst.visible = false;
		_inst.index = index;
		_inst.scale = scale;
		_inst.spd = speedd;
		_inst.curve = curve;
		return _inst;
	}
}

/// @desc Get the surface used in the shockwave system. Used for debugging generally.
/// @param {Struct} system_index description
function shockwave_get_surface(system_index) {
	__ppf_exception(!shockwave_exists(system_index), "Shockwaves system does not exist.");
	return system_index.__surf;
}

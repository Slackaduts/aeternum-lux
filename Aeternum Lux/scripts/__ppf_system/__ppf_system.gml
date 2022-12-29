
#macro PPFX_VERSION "v2.3"
#macro PPFX_RELEASE_DATE "December, 28, 2022"

show_debug_message("Post-Processing FX " + PPFX_VERSION + " | " + "Copyright (C) 2022 FoxyOfJungle");


// ppfx system shaders
#macro __PPF_SH_BASE __ppf_sh_render_base
#macro __PPF_SH_FXAA __ppf_sh_render_fxaa
#macro __PPF_SH_SUNSHAFTS __ppf_sh_render_sunshafts
#macro __PPF_SH_BLOOM_PRE_FILTER __ppf_sh_render_bloom_pre_filter
#macro __PPF_SH_BLOOM __ppf_sh_render_bloom
#macro __PPF_SH_DOF_COC __ppf_sh_render_dof_coc
#macro __PPF_SH_DOF_BOKEH __ppf_sh_render_dof_bokeh
#macro __PPF_SH_DOF __ppf_sh_render_dof
#macro __PPF_SH_MOTION_BLUR __ppf_sh_render_motion_blur
#macro __PPF_SH_RADIAL_BLUR __ppf_sh_render_radial_blur
#macro __PPF_SH_COLOR_GRADING __ppf_sh_render_color_grading
#macro __PPF_SH_PALETTE_SWAP __ppf_sh_render_palette_swap
#macro __PPF_SH_KAWASE_BLUR __ppf_sh_render_kawase_blur
#macro __PPF_SH_GAUSSIAN_BLUR __ppf_sh_render_gaussian_blur
#macro __PPF_SH_CHROMABER __ppf_sh_render_chromaber
#macro __PPF_SH_FINAL __ppf_sh_render_final

#macro __PPF_SH_DS_BOX4 __ppf_sh_ds_box4
#macro __PPF_SH_DS_BOX13 __ppf_sh_ds_box13
#macro __PPF_SH_US_TENT9 __ppf_sh_us_tent9

#macro __PPF_SH_GNMSK __ppf_sh_generic_mask
#macro __PPF_SH_SPRMSK __ppf_sh_sprite_mask
#macro __PPF_SH_BLEND_NORMALS __ppf_sh_blend_normals

#region verify compatibility
if (PPFX_CFG_HARDWARE_CHECKING) {
	if (!shaders_are_supported() && !__ppf_assert_and_func_array(shader_is_compiled, [
		__PPF_SH_DS_BOX4, __PPF_SH_DS_BOX13, __PPF_SH_US_TENT9, __PPF_SH_GNMSK, __PPF_SH_SPRMSK, __PPF_SH_BLEND_NORMALS,
		__PPF_SH_BASE, __PPF_SH_FXAA, __PPF_SH_SUNSHAFTS, __PPF_SH_BLOOM_PRE_FILTER, __PPF_SH_BLOOM, __PPF_SH_DOF_COC, __PPF_SH_DOF_BOKEH, __PPF_SH_DOF,  __PPF_SH_MOTION_BLUR,
		__PPF_SH_RADIAL_BLUR, __PPF_SH_COLOR_GRADING, __PPF_SH_PALETTE_SWAP, __PPF_SH_KAWASE_BLUR, __PPF_SH_GAUSSIAN_BLUR ,__PPF_SH_CHROMABER, __PPF_SH_FINAL, 
	])) {
		var _info = os_get_info(), _gpu = "", _is64 = "";
		switch(os_type) {
			case os_windows:
			case os_uwp: _gpu = "GPU: " + string(_info[? "video_adapter_description"]) + " | Dedicated Memory: " + string(_info[? "video_adapter_dedicatedvideomemory"]/1024/1024) + "MB"; break;
			case os_android: _gpu = "OpenGL: " + string(_info[? "GL_VERSION"]) + "\nGLSL: " + string(_info[? "GL_SHADING_LANGUAGE_VERSION"]) + "\nRenderer: " + string(_info[? "GL_RENDERER"]); break;
			case os_ios:
			case os_tvos:
			case os_linux:
			case os_macosx: _gpu = string(_info[? "gl_vendor_string"]) + " | " + string(_info[? "gl_renderer_string"]) + " | " + string(_info[? "gl_version_string"]); break;
			case os_xboxseriesxs: _gpu = string(_info[? "video_d3d12_currentrt"]); break;
			default: _gpu = "Unknown Device."; break;
		}
		_is64 = "is64bit: " + string(_info[? "is64bit"]) + " | ";
		var _trace = "\"Post-Processing FX\" will not work. Device not supported.\n\n" + _is64 + _gpu;
		__ppf_trace(_trace);
		show_message_async(_trace);
	}
}
#endregion

/// @desc Create post-processing system id to be used by the other functions.
/// @returns {struct} Post-Processing system id.
function ppfx_create() {
	__ppf_trace("System created. From: " + object_get_name(object_index));
	return new __ppfx_system();
}

/// @desc Check if post-processing system exists.
/// @param {struct} pp_index The returned variable by ppfx_create().
/// @returns {bool} description.
function ppfx_exists(pp_index) {
	return (is_struct(pp_index) && instanceof(pp_index) == "__ppfx_system");
}

/// @desc Destroy post-processing system.
/// @param {struct} pp_index The returned variable by ppfx_create().
/// @returns {undefined}
function ppfx_destroy(pp_index) {
	if ppfx_exists(pp_index) {
		__ppf_trace("System deleted. From: " + object_get_name(object_index));
		pp_index.__cleanup();
		delete pp_index;
	}
}

/// @desc Toggle whether the post-processing system can draw.
/// Please note that if disabled, it may still be rendered if rendering is enabled (will continue to demand GPU).
/// @param {struct} pp_index The returned variable by ppfx_create().
/// @param {real} enable Will be either true (enabled, the default value) or false (disabled). The drawing will toggle if nothing or -1 is entered.
/// @returns {undefined}
function ppfx_set_draw_enable(pp_index, enable=-1) {
	__ppf_exception(!ppfx_exists(pp_index), "Post-processing system does not exist.");
	if (enable == -1) {
		pp_index.__is_draw_enabled ^= 1;
	} else {
		pp_index.__is_draw_enabled = enable;
	}
}

/// @desc Toggle whether the post-processing system can render.
/// Please note that if enabled, it can render to the surface even if not drawing!
/// @param {struct} pp_index The returned variable by ppfx_create().
/// @param {real} enable Will be either true (enabled, the default value) or false (disabled). The rendering will toggle if nothing or -1 is entered.
/// @returns {undefined}
function ppfx_set_render_enable(pp_index, enable=-1) {
	__ppf_exception(!ppfx_exists(pp_index), "Post-processing system does not exist.");
	if (enable == -1) {
		pp_index.__is_render_enabled ^= 1;
	} else {
		pp_index.__is_render_enabled = enable;
	}
}

/// @desc Returns true if post-processing system drawing is enabled, and false if not.
/// @param {struct} pp_index The returned variable by ppfx_create().
/// @returns {bool}
function ppfx_is_draw_enabled(pp_index) {
	__ppf_exception(!ppfx_exists(pp_index), "System does not exist.");
	return pp_index.__is_draw_enabled;
}

/// @desc Returns true if post-processing system rendering is enabled, and false if not.
/// @param {struct} pp_index The returned variable by ppfx_create().
/// @returns {bool}
function ppfx_is_render_enabled(pp_index) {
	__ppf_exception(!ppfx_exists(pp_index), "System does not exist.");
	return pp_index.__is_render_enabled;
}

/// @desc Defines the overall draw intensity of the post-processing system.
/// The global intensity defines the interpolation between the original image and with the effects applied.
/// @param {struct} pp_index The returned variable by ppfx_create().
/// @param {real} value Intensity, 0 for none (default image), and 1 for full.
/// @returns {undefined}
function ppfx_set_global_intensity(pp_index, value) {
	__ppf_exception(!ppfx_exists(pp_index), "System does not exist.");
	pp_index.__global_intensity = value;
}

/// @desc Get the overall draw intensity of the post-processing system.
/// The global intensity defines the interpolation between the original image and with the effects applied.
/// This function returns a value between 0 and 1.
/// @param {struct} pp_index The returned variable by ppfx_create().
/// @returns {real} Value between 0 and 1.
function ppfx_get_global_intensity(pp_index) {
	__ppf_exception(!ppfx_exists(pp_index), "System does not exist.");
	return pp_index.__global_intensity;
}

/// @desc This function modifies the final rendering resolution of the post-processing system, based on a percentage (0 to 1).
/// @param {struct} pp_index The returned variable by ppfx_create().
/// @param {real} resolution Value from 0 to 1 that is multiplied internally with the final resolution of the system's final rendering view.
/// @returns {real} Value between 0 and 1.
function ppfx_set_render_resolution(pp_index, resolution) {
	__ppf_exception(!ppfx_exists(pp_index), "System does not exist.");
	pp_index.__render_res = clamp(resolution, 0.01, 1);
}

/// @desc Returns the post-processing system rendering percentage (0 to 1).
/// @param {struct} pp_index The returned variable by ppfx_create().
/// @returns {real} Normalized size.
function ppfx_get_render_resolution(pp_index) {
	__ppf_exception(!ppfx_exists(pp_index), "System does not exist.");
	return pp_index.__render_res;
}

/// @desc Returns the post-processing system final rendering surface.
/// @param {struct} pp_index The returned variable by ppfx_create().
/// @returns {Id.Surface} Surface index.
function ppfx_get_render_surface(pp_index) {
	__ppf_exception(!ppfx_exists(pp_index), "System does not exist.");
	return pp_index.__stack_surface[pp_index.__surf_index];
}

/// @desc Create a profile with predefined effects.
/// You can create multiple profiles with different effects and then load them in real time.
/// The order you add the effects to the array doesn't matter. They already have their own order.
/// @param {string} name Profile name. It only serves as a cosmetic and nothing else.
/// @param {array} effects_array Array with all effects structs.
/// @returns {struct} Profile struct.
function ppfx_profile_create(name, effects_array) {
	__ppf_exception(!is_string(name), "Invalid profile name.");
	__ppf_exception(!is_array(effects_array), "Parameter is not an array containing effects.");
	var _profile = {
		profile_name : name,
		settings : {},
		idd : sha1_string_utf8(get_timer()),
	}
	var i = 0, isize = array_length(effects_array);
	repeat(isize) {
		_profile.settings[$ effects_array[i].effect_name] = effects_array[i].sets;
		++i;
	}
	return _profile;
}

/// @desc This function loads a previously created profile.
/// Which means that the post-processing system will apply the settings of the effects contained in the profile, showing them consequently.
/// If you use the same post-processing system throughout the game and want to load different profiles later, you will need to reference the default profile, otherwise the effects settings will not update correctly.
/// @param {struct} pp_index The returned variable by ppfx_create().
/// @param {struct} profile_index Profile id created with ppfx_profile_create().
/// @returns {undefined}
function ppfx_profile_load(pp_index, profile_index) {
	gml_pragma("forceinline");
	__ppf_exception(!ppfx_exists(pp_index), "System does not exist.");
	__ppf_exception(!is_struct(profile_index), "Profile Index is not a struct.");
	if (pp_index.__current_profile != profile_index.idd) {
		__ppf_struct_copy(pp_index._pp_cfg_default, pp_index.__fx_cfg);
		__ppf_struct_copy(profile_index.settings, pp_index.__fx_cfg);
		__ppf_trace("Profile loaded: " + string(profile_index.profile_name));
		pp_index.__current_profile = profile_index.idd;
	}
}

/// @desc Get the name of the profile, created with ppfx_profile_create().
/// @param {struct} profile_index Profile id created with ppfx_profile_create().
/// @returns {string} Profile name.
function ppfx_profile_get_name(profile_index) {
	__ppf_exception(!is_struct(profile_index), "Profile Index is not a struct.");
	return profile_index.profile_name;
}

/// @desc Set the name of the profile, created with ppfx_profile_create().
/// @param {struct} profile_index Profile id created with ppfx_profile_create().
/// @param {string} name New profile name.
/// @returns {undefined}
function ppfx_profile_set_name(profile_index, name) {
	__ppf_exception(!is_struct(profile_index), "Profile Index is not a struct.");
	__ppf_exception(!is_string(name), "Invalid profile name.");
	profile_index.profile_name = name;
}

/// @desc This function toggles the effect rendering.
/// @param {struct} pp_index The returned variable by ppfx_create().
/// @param {real} effect_index Effect index. Use the enumerator, example: PP_EFFECT.BLOOM.
/// @param {real} enable Will be either true (enabled) or false (disabled). The rendering will toggle if nothing or -1 is entered.
/// @returns {undefined}
function ppfx_effect_set_enable(pp_index, effect_index, enable=-1) {
	__ppf_exception(!ppfx_exists(pp_index), "Post-processing system does not exist.");
	var _ef = pp_index.__effects_names[effect_index];
	__ppf_exception(variable_struct_names_count(pp_index.__fx_cfg[$ _ef]) <= 1, "It is not possible to toggle an effect that does not exist in the profile.");
	if (enable == -1) {
		pp_index.__fx_cfg[$ _ef].enabledd ^= 1;
	} else {
		pp_index.__fx_cfg[$ _ef].enabledd = enable;
	}
}

/// @desc Returns true if effect rendering is enabled, and false if not.
/// @param {struct} pp_index The returned variable by ppfx_create().
/// @param {real} effect_index Effect index. Use the enumerator, example: PP_EFFECT.BLOOM.
/// @returns {bool}
function ppfx_effect_is_enabled(pp_index, effect_index) {
	gml_pragma("forceinline");
	__ppf_exception(!ppfx_exists(pp_index), "Post-processing system does not exist.");
	var _ef = pp_index.__effects_names[effect_index];
	return pp_index.__fx_cfg[$ _ef].enabledd;
}

/// @desc Modify various parameters (settings) of an effect.
/// Use this if you want to modify an effect's attributes in real-time.
/// @param {struct} pp_index The returned variable by ppfx_create().
/// @param {real} effect_index Effect index. Use the enumerator, example: PP_EFFECT.BLOOM.
/// @param {array} params_array Array with the effect parameters. Use the pre-defined macros, for example: PP_BLOOM_COLOR.
/// @param {array} values_array Array with parameter values, must be in the same order.
/// @returns {undefined}
function ppfx_effect_set_parameters(pp_index, effect_index, params_array, values_array) {
	gml_pragma("forceinline");
	var _st = pp_index.__fx_cfg[$ pp_index.__effects_names[effect_index]];
	var _struct_vars = variable_struct_get_names(_st);
	var _len_st = array_length(_struct_vars);
	var _len_vars = array_length(params_array);
	var i = 0;
	repeat(_len_st) {
		var j = 0;
		repeat(_len_vars) {
			if (_struct_vars[i] == params_array[j]) {
				_st[$ params_array[j]] = values_array[j];
			}
			++j;
		}
		++i;
	}
}

/// @desc Modify a single parameter (setting) of an effect.
/// Use this to modify an effect's attribute in real-time.
/// @param {struct} pp_index The returned variable by ppfx_create().
/// @param {real} effect_index Effect index. Use the enumerator, example: PP_EFFECT.BLOOM.
/// @param {string} param Parameter macro. Example: PP_BLOOM_COLOR.
/// @param {any} value Parameter value. Example: make_color_rgb_ppfx(255, 255, 255).
/// @returns {undefined}
function ppfx_effect_set_parameter(pp_index, effect_index, param, value) {
	gml_pragma("forceinline");
	pp_index.__fx_cfg[$ pp_index.__effects_names[effect_index]][$ param] = value;
}

/// @desc Get a single parameter (setting) value of an effect.
/// @param {struct} pp_index The returned variable by ppfx_create().
/// @param {real} effect_index Effect index. Use the enumerator, example: PP_EFFECT.BLOOM.
/// @param {string} param Parameter macro. Example: PP_BLOOM_COLOR.
/// @returns {any}
function ppfx_effect_get_parameter(pp_index, effect_index, param) {
	gml_pragma("forceinline");
	return pp_index.__fx_cfg[$ pp_index.__effects_names[effect_index]][$ param];
}



/// @desc Draw post-processing system on screen.
/// @param {Id.Surface} surface Render surface to copy from. (You can use application_surface).
/// @param {real} x Horizontal X position of rendering.
/// @param {real} y Vertical Y position of rendering.
/// @param {real} w Width of the stretched game view.
/// @param {real} h Height of the stretched game view.
/// @param {real} view_w Width of your game view (Can use camera or window width, for example).
/// @param {real} view_h Height of your game view (Can use camera or window height, for example).
/// @param {struct} pp_index The returned variable by ppfx_create().
/// @returns {undefined}
function ppfx_draw(surface, x, y, w, h, view_w, view_h, pp_index) {
	__ppf_exception(surface == application_surface && event_number != ev_draw_post && event_number != ev_gui_begin, "Failed to draw using application_surface.\nIt can only be drawn in the Post-Draw or Draw GUI Begin event.");
	__ppf_exception(!ppfx_exists(pp_index), "Post-processing system does not exist.");
	with(pp_index) {
		if (!surface_exists(surface)) {
			if (__source_surf_exists) {
				__ppf_trace("WARNING: trying to draw post-processing using non-existent surface.");
				__source_surf_exists = false;
			}
			exit;
		}
		__source_surf_exists = true;
		var _sys_blendenable = gpu_get_blendenable(),
		_sys_blendmode = gpu_get_blendmode(),
		_sys_depth_disable = surface_get_depth_disable();
		// sets
		if (__is_render_enabled) {
			surface_depth_disable(true);
			
			// time
			__time += PPFX_CFG_SPEED;
			if (PPFX_CFG_TIMER > 0 && __time > PPFX_CFG_TIMER) __time = 0;
			
			// pos and size (read-only)
			__render_x = x;
			__render_y = y;
			__render_vw = view_w;
			__render_vh = view_h;
			
			// resize render resolution
			view_w *= __render_res;
			view_h *= __render_res;
			view_w -= frac(view_w);
			view_h -= frac(view_h);
			
			// delete stuff, to be updated
			if (__render_old_res != __render_res) {
				__cleanup();
				__render_old_res = __render_res;
			}
			
			#region stack 0 - base
			__surf_index = 0;
			if !surface_exists(__stack_surface[__surf_index]) {
				__stack_surface[__surf_index] = surface_create(view_w, view_h);
			}
			surface_set_target(__stack_surface[__surf_index]) {
				draw_clear_alpha(c_black, 0);
				gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
				
				shader_set(__PPF_SH_BASE);
				shader_set_uniform_f(__PPF_SU.base_main.pos_res, x, y, view_w, view_h);
				shader_set_uniform_f(__PPF_SU.base_main.u_time_n_intensity, __time, __global_intensity);
				shader_set_uniform_f_array(__PPF_SU.base_main.enabledd, [
					__fx_cfg.rotation.enabledd,
					__fx_cfg.zoom.enabledd,
					__fx_cfg.shake.enabledd,
					__fx_cfg.lens_distortion.enabledd,
					__fx_cfg.pixelize.enabledd,
					__fx_cfg.swirl.enabledd,
					__fx_cfg.panorama.enabledd,
					__fx_cfg.sine_wave.enabledd,
					__fx_cfg.glitch.enabledd,
					__fx_cfg.shockwaves.enabledd,
					__fx_cfg.displacemap.enabledd,
					__fx_cfg.white_balance.enabledd,
				]);
				
				// > effect: rotation
				if (__fx_cfg.rotation.enabledd) {
					shader_set_uniform_f(__PPF_SU.rotation.angle, __fx_cfg.rotation.angle);
				}
				// > effect: zoom
				if (__fx_cfg.zoom.enabledd) {
					shader_set_uniform_f(__PPF_SU.zoom.amount, __fx_cfg.zoom.amount);
					shader_set_uniform_f_array(__PPF_SU.zoom.center, __fx_cfg.zoom.center);
				}
				// > effect: shake
				if (__fx_cfg.shake.enabledd) {
					shader_set_uniform_f(__PPF_SU.shake.speedd, __fx_cfg.shake.speedd);
					shader_set_uniform_f(__PPF_SU.shake.magnitude, __fx_cfg.shake.magnitude);
					shader_set_uniform_f(__PPF_SU.shake.hspeedd, __fx_cfg.shake.hspeedd);
					shader_set_uniform_f(__PPF_SU.shake.vspeedd, __fx_cfg.shake.vspeedd);
				}
				// > effect: lens_distortion
				if (__fx_cfg.lens_distortion.enabledd) {
					shader_set_uniform_f(__PPF_SU.lens_distortion.amount, __fx_cfg.lens_distortion.amount);
				}
				// > effect: pixelize
				if (__fx_cfg.pixelize.enabledd) {
					shader_set_uniform_f(__PPF_SU.pixelize.amount, __fx_cfg.pixelize.amount);
					shader_set_uniform_f(__PPF_SU.pixelize.squares_max, __fx_cfg.pixelize.squares_max);
					shader_set_uniform_f(__PPF_SU.pixelize.steps, __fx_cfg.pixelize.steps);
				}
				// > effect: swirl
				if (__fx_cfg.swirl.enabledd) {
					shader_set_uniform_f(__PPF_SU.swirl.angle, __fx_cfg.swirl.angle);
					shader_set_uniform_f(__PPF_SU.swirl.radius, __fx_cfg.swirl.radius);
					shader_set_uniform_f_array(__PPF_SU.swirl.center, __fx_cfg.swirl.center);
				}
				// > effect: panorama
				if (__fx_cfg.panorama.enabledd) {
					shader_set_uniform_f(__PPF_SU.panorama.depthh, __fx_cfg.panorama.depthh);
					shader_set_uniform_f(__PPF_SU.panorama.is_horizontal, __fx_cfg.panorama.is_horizontal);
				}
				// > effect: sine_wave
				if (__fx_cfg.sine_wave.enabledd) {
					shader_set_uniform_f_array(__PPF_SU.sine_wave.frequency, __fx_cfg.sine_wave.frequency);
					shader_set_uniform_f_array(__PPF_SU.sine_wave.amplitude, __fx_cfg.sine_wave.amplitude);
					shader_set_uniform_f(__PPF_SU.sine_wave.speedd, __fx_cfg.sine_wave.speedd);
					shader_set_uniform_f_array(__PPF_SU.sine_wave.offset, __fx_cfg.sine_wave.offset);
				}
				// > effect: glitch
				if (__fx_cfg.glitch.enabledd) {
					shader_set_uniform_f(__PPF_SU.glitch.speedd, __fx_cfg.glitch.speedd);
					shader_set_uniform_f(__PPF_SU.glitch.block_size, __fx_cfg.glitch.block_size);
					shader_set_uniform_f(__PPF_SU.glitch.interval, __fx_cfg.glitch.interval);
					shader_set_uniform_f(__PPF_SU.glitch.intensity, __fx_cfg.glitch.intensity);
					shader_set_uniform_f(__PPF_SU.glitch.peak_amplitude1, __fx_cfg.glitch.peak_amplitude1);
					shader_set_uniform_f(__PPF_SU.glitch.peak_amplitude2, __fx_cfg.glitch.peak_amplitude2);
				}
				// > effect: shockwaves
				if (__fx_cfg.shockwaves.enabledd) {
					shader_set_uniform_f(__PPF_SU.shockwaves.amount, __fx_cfg.shockwaves.amount);
					shader_set_uniform_f(__PPF_SU.shockwaves.aberration, __fx_cfg.shockwaves.aberration);
					texture_set_stage(__PPF_SU.shockwaves.texture, __fx_cfg.shockwaves.texture);
					texture_set_stage(__PPF_SU.shockwaves.prisma_lut_tex, __fx_cfg.shockwaves.prisma_lut_tex);
				}
				// > effect: displacemap
				if (__fx_cfg.displacemap.enabledd) {
					shader_set_uniform_f(__PPF_SU.displacemap.amount, __fx_cfg.displacemap.amount);
					shader_set_uniform_f(__PPF_SU.displacemap.zoom, __fx_cfg.displacemap.zoom);
					shader_set_uniform_f(__PPF_SU.displacemap.angle, __fx_cfg.displacemap.angle);
					shader_set_uniform_f(__PPF_SU.displacemap.speedd, __fx_cfg.displacemap.speedd);
					texture_set_stage(__PPF_SU.displacemap.texture, __fx_cfg.displacemap.texture);
					shader_set_uniform_f_array(__PPF_SU.displacemap.offset, __fx_cfg.displacemap.offset);
				}
				// > effect: white_balance
				if (__fx_cfg.white_balance.enabledd) {
					shader_set_uniform_f(__PPF_SU.white_balance.temperature, __fx_cfg.white_balance.temperature);
					shader_set_uniform_f(__PPF_SU.white_balance.tint, __fx_cfg.white_balance.tint);
				}
				draw_surface_stretched(surface, 0, 0, view_w, view_h);
				shader_reset();
				gpu_set_blendmode(bm_normal);
				
				surface_reset_target();
			}
			#endregion
			
			#region stack 1 - fxaa
			if (__fx_cfg.fxaa.enabledd) {
				__surf_index++;
				if !surface_exists(__stack_surface[__surf_index]) {
					__stack_surface[__surf_index] = surface_create(view_w, view_h);
				}
				surface_set_target(__stack_surface[__surf_index]) {
					draw_clear_alpha(c_black, 0);
					gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
					
					shader_set(__PPF_SH_FXAA);
					shader_set_uniform_f(__PPF_SU.fxaa.resolution, view_w, view_h);
					shader_set_uniform_f(__PPF_SU.fxaa.strength, __fx_cfg.fxaa.strength);
					draw_surface_stretched(__stack_surface[__surf_index-1], 0, 0, view_w, view_h);
					shader_reset();
					
					gpu_set_blendmode(bm_normal);
					surface_reset_target();
				}
			}
			#endregion
			
			#region stack 2 - sunshafts
			if (__fx_cfg.sunshafts.enabledd) {
				// sets
				gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
				var _ds = clamp(__fx_cfg.sunshafts.downscale, 0.1, 1);
				var _ww = view_w*_ds, _hh = view_h*_ds;
				
				if (__sunshaft_downscale != _ds) {
					__ppf_surface_delete(__sunshaft_small_surface);
					__sunshaft_downscale = _ds;
				}
				
				var _source = __stack_surface[__surf_index];
				if !surface_exists(__sunshaft_small_surface) {
					__sunshaft_small_surface = surface_create(_ww, _hh);
				}
				surface_set_target(__sunshaft_small_surface);
				draw_clear_alpha(c_black, 0);
				draw_surface_stretched(_source, 0, 0, _ww, _hh);
				surface_reset_target();
				
				__surf_index++;
				if !surface_exists(__stack_surface[__surf_index]) {
					__stack_surface[__surf_index] = surface_create(view_w, view_h);
				}
				surface_set_target(__stack_surface[__surf_index]) {
					draw_clear_alpha(c_black, 0);
					
					shader_set(__PPF_SH_SUNSHAFTS);
					texture_set_stage(__PPF_SU.sunshafts.base_tex, surface_get_texture(__sunshaft_small_surface));
					shader_set_uniform_f(__PPF_SU.sunshafts.base_res, view_w, view_h);
					shader_set_uniform_f(__PPF_SU.sunshafts.u_time_n_intensity, __time, __global_intensity);
					
					shader_set_uniform_f_array(__PPF_SU.sunshafts.position, __fx_cfg.sunshafts.position);
					shader_set_uniform_f(__PPF_SU.sunshafts.center_smoothness, __fx_cfg.sunshafts.center_smoothness);
					shader_set_uniform_f(__PPF_SU.sunshafts.threshold, __fx_cfg.sunshafts.threshold);
					shader_set_uniform_f(__PPF_SU.sunshafts.intensity, __fx_cfg.sunshafts.intensity);
					shader_set_uniform_f(__PPF_SU.sunshafts.dimmer, __fx_cfg.sunshafts.dimmer);
					shader_set_uniform_f(__PPF_SU.sunshafts.scattering, __fx_cfg.sunshafts.scattering);
					shader_set_uniform_f(__PPF_SU.sunshafts.noise_enable, __fx_cfg.sunshafts.noise_enable);
					shader_set_uniform_f(__PPF_SU.sunshafts.rays_tiling, __fx_cfg.sunshafts.rays_tiling);
					shader_set_uniform_f(__PPF_SU.sunshafts.rays_speed, __fx_cfg.sunshafts.rays_speed);
					shader_set_uniform_f(__PPF_SU.sunshafts.dual_textures, __fx_cfg.sunshafts.dual_textures);
					
					texture_set_stage(__PPF_SU.sunshafts.world_tex, __fx_cfg.sunshafts.world_tex);
					texture_set_stage(__PPF_SU.sunshafts.sky_tex, __fx_cfg.sunshafts.sky_tex);
					texture_set_stage(__PPF_SU.sunshafts.noise_tex, __fx_cfg.sunshafts.noise_tex);
					gpu_set_tex_repeat_ext(__PPF_SU.sunshafts.noise_tex, true);
					
					draw_surface_stretched(__stack_surface[__surf_index-1], 0, 0, view_w, view_h);
					shader_reset();
					
					surface_reset_target();
				}
				gpu_set_blendmode(bm_normal);
			}
			#endregion
			
			#region stack 3 - bloom
			if (__fx_cfg.bloom.enabledd) {
				// sets
				var _cur_aa_filter = gpu_get_tex_filter();
				gpu_set_tex_filter(true);
				
				var _ww = view_w, _hh = view_h,
				_iterations = clamp(__fx_cfg.bloom.iterations, 2, 8),
				_reduce_banding = __fx_cfg.bloom.reduce_banding,
				_hq_d = __PPF_PASS_DS_BOX4, _hq_u = __PPF_PASS_US_TENT9;
				
				if (__fx_cfg.bloom.high_quality) {
					_hq_d = __PPF_PASS_DS_BOX13;
					_hq_u = __PPF_PASS_US_TENT9;
				}
				
				// > pre filter
				var _source = __stack_surface[__surf_index]; 
				if !surface_exists(__bloom_surface[0]) {
					__bloom_surface[0] = surface_create(_ww, _hh); // temporary surface
				}
				var _current_destination = __bloom_surface[0];
				__ppf_surface_blit(_source, _current_destination, __PPF_PASS_BLOOM_PREFILTER, {
					ww : _ww,
					hh : _hh,
					threshold : __fx_cfg.bloom.threshold,
					intensity : __fx_cfg.bloom.intensity,
				});
				var _current_source = _current_destination;
				
				// downsampling
				var i = 1; // there is already a texture in slot 0
				repeat(_iterations) {
					_ww /= 2;
					_hh /= 2;
					_ww -= frac(_ww);
					_hh -= frac(_hh);
					//if (min(_ww, _hh) < 2) break;
					if (_ww < 2 || _hh < 2) break;
					if !surface_exists(__bloom_surface[i]) {
						__bloom_surface[i] = surface_create(_ww, _hh);
					}
					_current_destination = __bloom_surface[i];
					__ppf_surface_blit(_current_source, _current_destination, _hq_d, {
						ww : _ww,
						hh : _hh,
						rb : _reduce_banding,
					});
					_current_source = _current_destination;
					++i;
				}
				
				// upsampling
				gpu_set_blendmode(bm_one);
				for(i -= 2; i >= 0; i--) { // 7, 6, 5, 4, 3, 2, 1, 0
					_current_destination = __bloom_surface[i];
					__ppf_surface_blit(_current_source, _current_destination, _hq_u, {
						ww : surface_get_width(_current_destination),
						hh : surface_get_height(_current_destination),
						rb : _reduce_banding,
					});
					_current_source = _current_destination;
				}
				gpu_set_blendmode(bm_normal);
				
				__surf_index++;
				if !surface_exists(__stack_surface[__surf_index]) {
					__stack_surface[__surf_index] = surface_create(view_w, view_h);
				}
				surface_set_target(__stack_surface[__surf_index]) {
					draw_clear_alpha(c_black, 0);
					gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
					
					shader_set(__PPF_SH_BLOOM);
					shader_set_uniform_f(__PPF_SU.bloom.resolution, view_w, view_h);
					shader_set_uniform_f(__PPF_SU.bloom.u_time_n_intensity, __time, __global_intensity);
					shader_set_uniform_f(__PPF_SU.bloom.threshold, __fx_cfg.bloom.threshold);
					shader_set_uniform_f(__PPF_SU.bloom.intensity, __fx_cfg.bloom.intensity);
					shader_set_uniform_f_array(__PPF_SU.bloom.colorr, __fx_cfg.bloom.colorr);
					shader_set_uniform_f(__PPF_SU.bloom.dirt_enable, __fx_cfg.bloom.dirt_enable);
					shader_set_uniform_f(__PPF_SU.bloom.dirt_intensity, __fx_cfg.bloom.dirt_intensity);
					shader_set_uniform_f(__PPF_SU.bloom.dirt_scale, __fx_cfg.bloom.dirt_scale);
					texture_set_stage(__PPF_SU.bloom.bloom_tex, surface_get_texture(_current_destination));
					texture_set_stage(__PPF_SU.bloom.dirt_tex, __fx_cfg.bloom.dirt_texture);
					gpu_set_tex_repeat_ext(__PPF_SU.bloom.dirt_tex, false);
					shader_set_uniform_f(__PPF_SU.bloom.debug, __fx_cfg.bloom.debug);
					draw_surface_stretched(__stack_surface[__surf_index-1], 0, 0, view_w, view_h);
					shader_reset();
					
					gpu_set_blendmode(bm_normal);
					surface_reset_target();
				}
				gpu_set_tex_filter(_cur_aa_filter);
			}
			#endregion
			
			#region stack 4 - depth of field
			if (__fx_cfg.depth_of_field.enabledd) {
				// sets
				var _source = __stack_surface[__surf_index];
				
				// coc
				var _ww = view_w, _hh = view_h;
				if !surface_exists(__dof_surface[0]) __dof_surface[0] = surface_create(_ww, _hh); 
				var _cur_aa_filter = gpu_get_tex_filter();
				gpu_set_tex_filter(false);
				__ppf_surface_blit(_source, __dof_surface[0], __PPF_PASS_DOF_COC, {
					lens_distortion_enable : __fx_cfg.lens_distortion.enabledd,
					lens_distortion_amount : __fx_cfg.lens_distortion.enabledd ? __fx_cfg.lens_distortion.amount : 0,
					radius : __fx_cfg.depth_of_field.radius,
					focus_distance : __fx_cfg.depth_of_field.focus_distance,
					focus_range : __fx_cfg.depth_of_field.focus_range,
					use_zdepth : __fx_cfg.depth_of_field.use_zdepth,
					zdepth_tex : __fx_cfg.depth_of_field.zdepth_tex,
				});
				gpu_set_tex_filter(true);
				
				gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
				// pre filter
				_ww = view_w/2; _hh = view_h/2; // half res
				if !surface_exists(__dof_surface[1]) __dof_surface[1] = surface_create(_ww, _hh);
				__ppf_surface_blit_alpha(_source, __dof_surface[1], __PPF_PASS_DS_BOX13, {
					ww : _ww,
					hh : _hh,
					rb : false,
				});
				
				// bokeh
				if !surface_exists(__dof_surface[2]) __dof_surface[2] = surface_create(_ww, _hh);
				__ppf_surface_blit_alpha(__dof_surface[1], __dof_surface[2], __PPF_PASS_DOF_BOKEH, {
					ww : _ww,
					hh : _hh,
					time : __time,
					global_intensity : __global_intensity,
					radius : __fx_cfg.depth_of_field.radius,
					intensity : __fx_cfg.depth_of_field.intensity,
					shaped : __fx_cfg.depth_of_field.shaped,
					blades_aperture : __fx_cfg.depth_of_field.blades_aperture,
					blades_angle : __fx_cfg.depth_of_field.blades_angle,
					debug : __fx_cfg.depth_of_field.debug,
					coc_tex : surface_get_texture(__dof_surface[0]),
				});
				
				// post filter
				//_ww /= 2; _hh /= 2;
				if !surface_exists(__dof_surface[3]) __dof_surface[3] = surface_create(_ww, _hh);
				__ppf_surface_blit_alpha(__dof_surface[2], __dof_surface[3], __PPF_PASS_US_TENT9, {
					ww : _ww,
					hh : _hh,
					rb : false,
				});
				
				__surf_index++;
				if !surface_exists(__stack_surface[__surf_index]) {
					__stack_surface[__surf_index] = surface_create(view_w, view_h);
				}
				surface_set_target(__stack_surface[__surf_index]) {
					draw_clear_alpha(c_black, 0);
					
					shader_set(__PPF_SH_DOF);
					texture_set_stage(__PPF_SU.depth_of_field.final_coc_tex, surface_get_texture(__dof_surface[0]));
					texture_set_stage(__PPF_SU.depth_of_field.final_dof_tex, surface_get_texture(__dof_surface[3]));
					draw_surface_stretched(__stack_surface[__surf_index-1], 0, 0, view_w, view_h);
					shader_reset();
					
					surface_reset_target();
				}
				gpu_set_tex_filter(_cur_aa_filter);
				gpu_set_blendmode(bm_normal);
			}
			#endregion
			
			#region stack 5 - motion blur
			if (__fx_cfg.motion_blur.enabledd) {
				__surf_index++;
				if !surface_exists(__stack_surface[__surf_index]) {
					__stack_surface[__surf_index] = surface_create(view_w, view_h);
				}
				surface_set_target(__stack_surface[__surf_index]) {
					draw_clear_alpha(c_black, 0);
					gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
					
					shader_set(__PPF_SH_MOTION_BLUR);
					shader_set_uniform_f(__PPF_SU.motion_blur.u_time_n_intensity, __time, __global_intensity);
					shader_set_uniform_f(__PPF_SU.motion_blur.angle, __fx_cfg.motion_blur.angle);
					shader_set_uniform_f(__PPF_SU.motion_blur.radius, __fx_cfg.motion_blur.radius);
					shader_set_uniform_f_array(__PPF_SU.motion_blur.center, __fx_cfg.motion_blur.center);
					shader_set_uniform_f(__PPF_SU.motion_blur.mask_power, __fx_cfg.motion_blur.mask_power);
					shader_set_uniform_f(__PPF_SU.motion_blur.mask_scale, __fx_cfg.motion_blur.mask_scale);
					shader_set_uniform_f(__PPF_SU.motion_blur.mask_smoothness, __fx_cfg.motion_blur.mask_smoothness);
					texture_set_stage(__PPF_SU.motion_blur.overlay_texture, __fx_cfg.motion_blur.overlay_texture);
					draw_surface_stretched(__stack_surface[__surf_index-1], 0, 0, view_w, view_h);
					shader_reset();
					
					gpu_set_blendmode(bm_normal);
					surface_reset_target();
				}
			}
			#endregion
			
			#region stack 6 - radial blur
			if (__fx_cfg.blur_radial.enabledd) {
				__surf_index++;
				if !surface_exists(__stack_surface[__surf_index]) {
					__stack_surface[__surf_index] = surface_create(view_w, view_h);
				}
				surface_set_target(__stack_surface[__surf_index]) {
					draw_clear_alpha(c_black, 0);
					gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
					
			 		shader_set(__PPF_SH_RADIAL_BLUR);
					shader_set_uniform_f(__PPF_SU.blur_radial.u_time_n_intensity, __time, __global_intensity);
					shader_set_uniform_f(__PPF_SU.blur_radial.radius, __fx_cfg.blur_radial.radius);
					shader_set_uniform_f_array(__PPF_SU.blur_radial.center, __fx_cfg.blur_radial.center);
					shader_set_uniform_f(__PPF_SU.blur_radial.inner, __fx_cfg.blur_radial.inner);
					draw_surface_stretched(__stack_surface[__surf_index-1], 0, 0, view_w, view_h);
					shader_reset();
					
					gpu_set_blendmode(bm_normal);
					surface_reset_target();
				}
			}
			#endregion
			
			#region stack 7 - color grading
			__surf_index++;
			if !surface_exists(__stack_surface[__surf_index]) {
				__stack_surface[__surf_index] = surface_create(view_w, view_h);
			}
			surface_set_target(__stack_surface[__surf_index]) {
				draw_clear_alpha(c_black, 0);
				gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
				
				shader_set(__PPF_SH_COLOR_GRADING);
				shader_set_uniform_f(__PPF_SU.color_grading.pos_res, x, y, view_w, view_h);
				shader_set_uniform_f(__PPF_SU.color_grading.u_time_n_intensity, __time, __global_intensity);
				shader_set_uniform_f_array(__PPF_SU.color_grading.enabledd, [
					__fx_cfg.lens_distortion.enabledd,
					__fx_cfg.lut3d.enabledd,
					__fx_cfg.shadow_midtone_highlight.enabledd,
					__fx_cfg.exposure.enabledd,
					__fx_cfg.brightness.enabledd,
					__fx_cfg.saturation.enabledd,
					__fx_cfg.contrast.enabledd,
					__fx_cfg.tone_mapping.enabledd,
					__fx_cfg.lift_gamma_gain.enabledd,
					__fx_cfg.hue_shift.enabledd,
					__fx_cfg.colorize.enabledd,
					__fx_cfg.posterization.enabledd,
					__fx_cfg.invert_colors.enabledd,
					__fx_cfg.texture_overlay.enabledd,
					__fx_cfg.border.enabledd,
				]);
				
				// > [d] effect: lens_distortion
				if (__fx_cfg.lens_distortion.enabledd) {
					shader_set_uniform_f(__PPF_SU.lens_distortion.amount_c, __fx_cfg.lens_distortion.amount);
				}
				// > effect: lut3d
				if (__fx_cfg.lut3d.enabledd) {
					texture_set_stage(__PPF_SU.lut3d.tex_lookup, __fx_cfg.lut3d.texture);
					shader_set_uniform_f(__PPF_SU.lut3d.intensity, __fx_cfg.lut3d.intensity);
					shader_set_uniform_f_array(__PPF_SU.lut3d.size, __fx_cfg.lut3d.size);
					shader_set_uniform_f(__PPF_SU.lut3d.squares, __fx_cfg.lut3d.squares);
				}
				// > effect: shadow_midtone_highlight
				if (__fx_cfg.shadow_midtone_highlight.enabledd) {
					shader_set_uniform_f_array(__PPF_SU.shadow_midtone_highlight.shadow_color, __fx_cfg.shadow_midtone_highlight.shadow_color);
					shader_set_uniform_f_array(__PPF_SU.shadow_midtone_highlight.midtone_color, __fx_cfg.shadow_midtone_highlight.midtone_color);
					shader_set_uniform_f_array(__PPF_SU.shadow_midtone_highlight.highlight_color, __fx_cfg.shadow_midtone_highlight.highlight_color);
					shader_set_uniform_f(__PPF_SU.shadow_midtone_highlight.shadow_range, __fx_cfg.shadow_midtone_highlight.shadow_range);
					shader_set_uniform_f(__PPF_SU.shadow_midtone_highlight.highlight_range, __fx_cfg.shadow_midtone_highlight.highlight_range);
				}
				// > effect: exposure
				if (__fx_cfg.exposure.enabledd) {
					shader_set_uniform_f(__PPF_SU.exposure.value, __fx_cfg.exposure.value);
				}
				// > effect: brightness
				if (__fx_cfg.brightness.enabledd) {
					shader_set_uniform_f(__PPF_SU.brightness.value, __fx_cfg.brightness.value);
				}
				// > effect: saturation
				if (__fx_cfg.saturation.enabledd) {
					shader_set_uniform_f(__PPF_SU.saturation.value, __fx_cfg.saturation.value);
				}
				// > effect: contrast
				if (__fx_cfg.contrast.enabledd) {
					shader_set_uniform_f(__PPF_SU.contrast.value, __fx_cfg.contrast.value);
				}
				// > effect: tone_mapping
				if (__fx_cfg.tone_mapping.enabledd) {
					shader_set_uniform_i(__PPF_SU.tone_mapping.mode, __fx_cfg.tone_mapping.mode);
				}
				// > effect: lift_gamma_gain
				if (__fx_cfg.lift_gamma_gain.enabledd) {
					shader_set_uniform_f_array(__PPF_SU.lift_gamma_gain.lift, __fx_cfg.lift_gamma_gain.lift);
					shader_set_uniform_f_array(__PPF_SU.lift_gamma_gain.gamma, __fx_cfg.lift_gamma_gain.gamma);
					shader_set_uniform_f_array(__PPF_SU.lift_gamma_gain.gain, __fx_cfg.lift_gamma_gain.gain);
				}
				// > effect: hue_shift
				if (__fx_cfg.hue_shift.enabledd) {
					shader_set_uniform_f_array(__PPF_SU.hue_shift.colorr, __fx_cfg.hue_shift.colorr);
				}
				// > effect: colorize
				if (__fx_cfg.colorize.enabledd) {
					shader_set_uniform_f_array(__PPF_SU.colorize.colorr, __fx_cfg.colorize.colorr);
					shader_set_uniform_f(__PPF_SU.colorize.intensity, __fx_cfg.colorize.intensity);
					shader_set_uniform_f(__PPF_SU.colorize.darkness, __fx_cfg.colorize.darkness);
				}
				// > effect: posterization
				if (__fx_cfg.posterization.enabledd) {
					shader_set_uniform_f(__PPF_SU.posterization.color_factor, __fx_cfg.posterization.color_factor);
				}
				// > effect: invert_colors
				if (__fx_cfg.invert_colors.enabledd) {
					shader_set_uniform_f(__PPF_SU.invert_colors.intensity, __fx_cfg.invert_colors.intensity);
				}
				// > effect: texture_overlay
				if (__fx_cfg.texture_overlay.enabledd) {
					shader_set_uniform_f(__PPF_SU.texture_overlay.intensity, __fx_cfg.texture_overlay.intensity);
					shader_set_uniform_f(__PPF_SU.texture_overlay.zoom, __fx_cfg.texture_overlay.zoom);
					texture_set_stage(__PPF_SU.texture_overlay.texture, __fx_cfg.texture_overlay.texture);
				}
				// > [d] effect: border
				if (__fx_cfg.border.enabledd) {
					shader_set_uniform_f(__PPF_SU.border.curvature_c, __fx_cfg.border.curvature);
					shader_set_uniform_f(__PPF_SU.border.smooth_c, __fx_cfg.border.smooth);
					shader_set_uniform_f_array(__PPF_SU.border.colorr_c, __fx_cfg.border.colorr);
				}
				draw_surface_stretched(__stack_surface[__surf_index-1], 0, 0, view_w, view_h);
				shader_reset();
				
				gpu_set_blendmode(bm_normal);
				surface_reset_target();
			}
			#endregion
			
			#region stack 8 - palette swap
			if (__fx_cfg.palette_swap.enabledd) {
				__surf_index++;
				var _cur_aa_filter = gpu_get_tex_filter();
				gpu_set_tex_filter_ext(__PPF_SU.palette_swap.texture, !__fx_cfg.palette_swap.limit_colors);
				if !surface_exists(__stack_surface[__surf_index]) {
					__stack_surface[__surf_index] = surface_create(view_w, view_h);
				}
				surface_set_target(__stack_surface[__surf_index]) {
					draw_clear_alpha(c_black, 0);
					gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
					
					shader_set(__PPF_SH_PALETTE_SWAP);
					shader_set_uniform_f(__PPF_SU.palette_swap.u_time_n_intensity, __time, __global_intensity);
					shader_set_uniform_f(__PPF_SU.palette_swap.row, __fx_cfg.palette_swap.row);
					shader_set_uniform_f(__PPF_SU.palette_swap.pal_height, __fx_cfg.palette_swap.pal_height);
					shader_set_uniform_f(__PPF_SU.palette_swap.threshold, __fx_cfg.palette_swap.threshold);
					shader_set_uniform_f(__PPF_SU.palette_swap.flip, __fx_cfg.palette_swap.flip);
					texture_set_stage(__PPF_SU.palette_swap.texture, __fx_cfg.palette_swap.texture);
					draw_surface_stretched(__stack_surface[__surf_index-1], 0, 0, view_w, view_h);
					shader_reset();
					
					gpu_set_blendmode(bm_normal);
					surface_reset_target();
				}
				gpu_set_tex_filter(_cur_aa_filter);
			}
			#endregion
			
			#region stack 9 - kawase blur
			if (__fx_cfg.blur_kawase.enabledd) {
				// sets
				var _ds = __fx_cfg.blur_kawase.downscale,
				_amount = __fx_cfg.blur_kawase.amount,
				_iterations = clamp(__fx_cfg.blur_kawase.iterations * _amount, 1, 8),
				_ww = view_w, _hh = view_h,
				
				_source = __stack_surface[__surf_index],
				_current_destination = _source,
				_current_source = _source,
				
				_cur_aa_filter = gpu_get_tex_filter();
				
				gpu_set_tex_filter(true);
				gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
				
				// downsampling
				var i = 0;
				repeat(_iterations) {
					_ww /= _ds;
					_hh /= _ds;
					_ww -= frac(_ww);
					_hh -= frac(_hh);
					//if (min(_ww, _hh) < 2) break;
					if (_ww < 2 || _hh < 2) break;
					if !surface_exists(__kawase_blur_surface[i]) {
						__kawase_blur_surface[i] = surface_create(_ww, _hh);
					}
					_current_destination = __kawase_blur_surface[i];
					__ppf_surface_blit_alpha(_current_source, _current_destination, 1, {
						ww : _ww,
						hh : _hh,
						rb : false,
					});
					_current_source = _current_destination;
					++i;
				}
				
				// upsampling
				for(i -= 2; i >= 0; i--) {
					_current_destination = __kawase_blur_surface[i];
					__ppf_surface_blit_alpha(_current_source, _current_destination, 3, {
						ww : surface_get_width(_current_destination),
						hh : surface_get_height(_current_destination),
						rb : false,
					});
					_current_source = _current_destination;
				}
				
				__surf_index++;
				if !surface_exists(__stack_surface[__surf_index]) {
					__stack_surface[__surf_index] = surface_create(view_w, view_h);
				}
				surface_set_target(__stack_surface[__surf_index]) {
					draw_clear_alpha(c_black, 0);
					
					shader_set(__PPF_SH_KAWASE_BLUR);
					shader_set_uniform_f(__PPF_SU.blur_kawase.u_time_n_intensity, __time, __global_intensity);
					shader_set_uniform_f(__PPF_SU.blur_kawase.mask_power, __fx_cfg.blur_kawase.mask_power);
					shader_set_uniform_f(__PPF_SU.blur_kawase.mask_scale, __fx_cfg.blur_kawase.mask_scale);
					shader_set_uniform_f(__PPF_SU.blur_kawase.mask_smoothness, __fx_cfg.blur_kawase.mask_smoothness);
					texture_set_stage(__PPF_SU.blur_kawase.blur_tex, surface_get_texture(_current_destination));
					draw_surface_stretched(__stack_surface[__surf_index-1], 0, 0, view_w, view_h);
					shader_reset();
					
					surface_reset_target();
				}
				gpu_set_blendmode(bm_normal);
				gpu_set_tex_filter(_cur_aa_filter);
			}
			#endregion
			
			#region stack 10 - gaussian blur
			if (__fx_cfg.blur_gaussian.enabledd) {
				var _source = __stack_surface[__surf_index],
				_ds = clamp(__fx_cfg.blur_gaussian.downscale, 0.1, 1),
				_ww = view_w*_ds, _hh = view_h*_ds,
				
				_cur_aa_filter = gpu_get_tex_filter();
				gpu_set_tex_filter(true);
				
				if (__gaussian_blur_downscale != _ds) {
					__ppf_surface_delete(__gaussian_blur_ping_surface);
					__ppf_surface_delete(__gaussian_blur_pong_surface);
					__gaussian_blur_downscale = _ds;
				}
				if !surface_exists(__gaussian_blur_ping_surface) {
					__gaussian_blur_ping_surface = surface_create(_ww, _hh);
					__gaussian_blur_pong_surface = surface_create(_ww/2, _hh/2);
				}
				
				gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
				shader_set(__PPF_SH_GAUSSIAN_BLUR);
				shader_set_uniform_f(__PPF_SU.blur_gaussian.resolution, _ww, _hh);
				shader_set_uniform_f(__PPF_SU.blur_gaussian.u_time_n_intensity, __time, __global_intensity);
				shader_set_uniform_f(__PPF_SU.blur_gaussian.amount, __fx_cfg.blur_gaussian.amount);
				
				surface_set_target(__gaussian_blur_ping_surface);
				draw_clear_alpha(c_black, 0);
				draw_surface_stretched(_source, 0, 0, _ww, _hh);
				surface_reset_target();
				
				surface_set_target(__gaussian_blur_pong_surface);
				draw_clear_alpha(c_black, 0);
				draw_surface_stretched(__gaussian_blur_ping_surface, 0, 0, _ww/2, _hh/2);
				surface_reset_target();
				shader_reset();
				
				__surf_index++;
				if !surface_exists(__stack_surface[__surf_index]) {
					__stack_surface[__surf_index] = surface_create(view_w, view_h);
				}
				surface_set_target(__stack_surface[__surf_index]) {
					draw_clear_alpha(c_black, 0);
					
					shader_set(__PPF_SH_GNMSK);
					shader_set_uniform_f(__PPF_SU.gnmask_power, __fx_cfg.blur_gaussian.mask_power);
					shader_set_uniform_f(__PPF_SU.gnmask_scale, __fx_cfg.blur_gaussian.mask_scale);
					shader_set_uniform_f(__PPF_SU.gnmask_smoothness, __fx_cfg.blur_gaussian.mask_smoothness);
					texture_set_stage(__PPF_SU.gnmask_texture, surface_get_texture(__gaussian_blur_pong_surface));
					draw_surface_stretched(__stack_surface[__surf_index-1], 0, 0, view_w, view_h);
					shader_reset();
					
					surface_reset_target();
				}
				gpu_set_blendmode(bm_normal);
				gpu_set_tex_filter(_cur_aa_filter);
			}
			#endregion
			
			#region stack 11 - chromatic aberration
			if (__fx_cfg.chromaber.enabledd) {
				__surf_index++;
				var _cur_aa_filter = gpu_get_tex_filter();
				gpu_set_tex_filter_ext(__PPF_SU.chromaber.prisma_lut_tex, false);
				if !surface_exists(__stack_surface[__surf_index]) {
					__stack_surface[__surf_index] = surface_create(view_w, view_h);
				}
				surface_set_target(__stack_surface[__surf_index]) {
					draw_clear_alpha(c_black, 0);
					gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
					
					shader_set(__PPF_SH_CHROMABER);
					shader_set_uniform_f(__PPF_SU.chromaber.pos_res, x, y, view_w, view_h);
					shader_set_uniform_f(__PPF_SU.chromaber.u_time_n_intensity, __time, __global_intensity);
					shader_set_uniform_f(__PPF_SU.chromaber.angle, __fx_cfg.chromaber.angle);
					shader_set_uniform_f(__PPF_SU.chromaber.intensity, __fx_cfg.chromaber.intensity);
					shader_set_uniform_f(__PPF_SU.chromaber.only_outer, __fx_cfg.chromaber.only_outer);
					shader_set_uniform_f(__PPF_SU.chromaber.center_radius, __fx_cfg.chromaber.center_radius);
					shader_set_uniform_f(__PPF_SU.chromaber.blur_enable, __fx_cfg.chromaber.blur_enable);
					texture_set_stage(__PPF_SU.chromaber.prisma_lut_tex, __fx_cfg.chromaber.prisma_lut_tex);
					draw_surface_stretched(__stack_surface[__surf_index-1], 0, 0, view_w, view_h);
					shader_reset();
					
					gpu_set_blendmode(bm_normal);
					surface_reset_target();
				}
				gpu_set_tex_filter(_cur_aa_filter);
			}
			#endregion
			
			#region stack 12 - final
			__surf_index++;
			if !surface_exists(__stack_surface[__surf_index]) {
				__stack_surface[__surf_index] = surface_create(view_w, view_h);
			}
			surface_set_target(__stack_surface[__surf_index]) {
				draw_clear_alpha(c_black, 0);
				gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
				
				shader_set(__PPF_SH_FINAL);
				shader_set_uniform_f(__PPF_SU.base_final.pos_res, x, y, view_w, view_h);
				shader_set_uniform_f(__PPF_SU.base_final.u_time_n_intensity, __time, __global_intensity);
				shader_set_uniform_f_array(__PPF_SU.base_final.enabledd, [
					__fx_cfg.lens_distortion.enabledd,
					__fx_cfg.mist.enabledd,
					__fx_cfg.speedlines.enabledd,
					__fx_cfg.dithering.enabledd,
					__fx_cfg.noise_grain.enabledd,
					__fx_cfg.vignette.enabledd,
					__fx_cfg.nes_fade.enabledd,
					__fx_cfg.scanlines.enabledd,
					__fx_cfg.fade.enabledd,
					__fx_cfg.cinema_bars.enabledd,
					__fx_cfg.color_blindness.enabledd,
					__fx_cfg.channels.enabledd,
					__fx_cfg.border.enabledd,
				]);
				
				// > [d] effect: lens_distortion
				if (__fx_cfg.lens_distortion.enabledd) {
					shader_set_uniform_f(__PPF_SU.lens_distortion.amount_f, __fx_cfg.lens_distortion.amount);
				}
				// > effect: mist
				if (__fx_cfg.mist.enabledd) {
					shader_set_uniform_f(__PPF_SU.mist.intensity, __fx_cfg.mist.intensity);
					shader_set_uniform_f(__PPF_SU.mist.scale, __fx_cfg.mist.scale);
					shader_set_uniform_f(__PPF_SU.mist.tiling, __fx_cfg.mist.tiling);
					shader_set_uniform_f(__PPF_SU.mist.speedd, __fx_cfg.mist.speedd);
					shader_set_uniform_f(__PPF_SU.mist.angle, __fx_cfg.mist.angle);
					shader_set_uniform_f(__PPF_SU.mist.contrast, __fx_cfg.mist.contrast);
					shader_set_uniform_f(__PPF_SU.mist.powerr, __fx_cfg.mist.powerr);
					shader_set_uniform_f(__PPF_SU.mist.remap, __fx_cfg.mist.remap);
					shader_set_uniform_f_array(__PPF_SU.mist.colorr, __fx_cfg.mist.colorr);
					shader_set_uniform_f(__PPF_SU.mist.mix, __fx_cfg.mist.mix);
					shader_set_uniform_f(__PPF_SU.mist.mix_threshold, __fx_cfg.mist.mix_threshold);
					texture_set_stage(__PPF_SU.mist.noise_tex, __fx_cfg.mist.noise_tex);
					gpu_set_tex_repeat_ext(__PPF_SU.mist.noise_tex, true);
					shader_set_uniform_f_array(__PPF_SU.mist.offset, __fx_cfg.mist.offset);
					shader_set_uniform_f(__PPF_SU.mist.fade_amount, __fx_cfg.mist.fade_amount);
					shader_set_uniform_f(__PPF_SU.mist.fade_angle, __fx_cfg.mist.fade_angle);
				}
				// > effect: speedlines
				if (__fx_cfg.speedlines.enabledd) {
					shader_set_uniform_f(__PPF_SU.speedlines.scale, __fx_cfg.speedlines.scale);
					shader_set_uniform_f(__PPF_SU.speedlines.tiling, __fx_cfg.speedlines.tiling);
					shader_set_uniform_f(__PPF_SU.speedlines.speedd, __fx_cfg.speedlines.speedd);
					shader_set_uniform_f(__PPF_SU.speedlines.rot_speed, __fx_cfg.speedlines.rot_speed);
					shader_set_uniform_f(__PPF_SU.speedlines.contrast, __fx_cfg.speedlines.contrast);
					shader_set_uniform_f(__PPF_SU.speedlines.powerr, __fx_cfg.speedlines.powerr);
					shader_set_uniform_f(__PPF_SU.speedlines.remap, __fx_cfg.speedlines.remap);
					shader_set_uniform_f(__PPF_SU.speedlines.mask_power, __fx_cfg.speedlines.mask_power);
					shader_set_uniform_f(__PPF_SU.speedlines.mask_scale, __fx_cfg.speedlines.mask_scale);
					shader_set_uniform_f(__PPF_SU.speedlines.mask_smoothness, __fx_cfg.speedlines.mask_smoothness);
					shader_set_uniform_f_array(__PPF_SU.speedlines.colorr, __fx_cfg.speedlines.colorr);
					texture_set_stage(__PPF_SU.speedlines.noise_tex, __fx_cfg.speedlines.noise_tex);
					gpu_set_tex_repeat_ext(__PPF_SU.speedlines.noise_tex, true);
				}
				// > effect: dithering
				if (__fx_cfg.dithering.enabledd) {
					texture_set_stage(__PPF_SU.dithering.bayer_texture, __fx_cfg.dithering.bayer_texture);
					shader_set_uniform_f(__PPF_SU.dithering.threshold, __fx_cfg.dithering.threshold);
					shader_set_uniform_f(__PPF_SU.dithering.strength, __fx_cfg.dithering.strength);
					shader_set_uniform_f(__PPF_SU.dithering.mode, __fx_cfg.dithering.mode);
					shader_set_uniform_i(__PPF_SU.dithering.coord_absolute, __fx_cfg.dithering.coord_absolute);
					shader_set_uniform_f(__PPF_SU.dithering.bayer_size, __fx_cfg.dithering.bayer_size);
					//gpu_set_tex_filter_ext(__PPF_SU.dithering.bayer_texture, false); // not working ??
				}
				// > effect: noise_grain
				if (__fx_cfg.noise_grain.enabledd) {
					shader_set_uniform_f(__PPF_SU.noise_grain.intensity, __fx_cfg.noise_grain.intensity);
					shader_set_uniform_f(__PPF_SU.noise_grain.scale, __fx_cfg.noise_grain.scale);
					shader_set_uniform_f(__PPF_SU.noise_grain.mix, __fx_cfg.noise_grain.mix);
					texture_set_stage(__PPF_SU.noise_grain.noise_tex, __fx_cfg.noise_grain.noise_tex);
					gpu_set_tex_repeat_ext(__PPF_SU.noise_grain.noise_tex, true);
				}
				// > effect: vignette
				if (__fx_cfg.vignette.enabledd) {
					shader_set_uniform_f(__PPF_SU.vignette.intensity, __fx_cfg.vignette.intensity);
					shader_set_uniform_f(__PPF_SU.vignette.curvature, __fx_cfg.vignette.curvature);
					shader_set_uniform_f(__PPF_SU.vignette.inner, __fx_cfg.vignette.inner);
					shader_set_uniform_f(__PPF_SU.vignette.outer, __fx_cfg.vignette.outer);
					shader_set_uniform_f_array(__PPF_SU.vignette.colorr, __fx_cfg.vignette.colorr);
					shader_set_uniform_f_array(__PPF_SU.vignette.center, __fx_cfg.vignette.center);
					shader_set_uniform_f(__PPF_SU.vignette.rounded, __fx_cfg.vignette.rounded);
					shader_set_uniform_f(__PPF_SU.vignette.linear, __fx_cfg.vignette.linear);
				}
				// > effect: nes_fade
				if (__fx_cfg.nes_fade.enabledd) {
					shader_set_uniform_f(__PPF_SU.nes_fade.amount, __fx_cfg.nes_fade.amount);
					shader_set_uniform_f(__PPF_SU.nes_fade.levels, __fx_cfg.nes_fade.levels);
				}
				// > effect: scanlines
				if (__fx_cfg.scanlines.enabledd) {
					shader_set_uniform_f(__PPF_SU.scanlines.intensity, __fx_cfg.scanlines.intensity);
					shader_set_uniform_f(__PPF_SU.scanlines.speedd, __fx_cfg.scanlines.speedd);
					shader_set_uniform_f(__PPF_SU.scanlines.amount, __fx_cfg.scanlines.amount);
					shader_set_uniform_f_array(__PPF_SU.scanlines.colorr, __fx_cfg.scanlines.colorr);
					shader_set_uniform_f(__PPF_SU.scanlines.mask_power, __fx_cfg.scanlines.mask_power);
					shader_set_uniform_f(__PPF_SU.scanlines.mask_scale, __fx_cfg.scanlines.mask_scale);
					shader_set_uniform_f(__PPF_SU.scanlines.mask_smoothness, __fx_cfg.scanlines.mask_smoothness);
				}
				// > effect: fade
				if (__fx_cfg.fade.enabledd) {
					shader_set_uniform_f(__PPF_SU.fade.amount, __fx_cfg.fade.amount);
					shader_set_uniform_f_array(__PPF_SU.fade.colorr, __fx_cfg.fade.colorr);
				}
				// > effect: cinema_bars
				if (__fx_cfg.cinema_bars.enabledd) {
					shader_set_uniform_f(__PPF_SU.cinema_bars.amount, __fx_cfg.cinema_bars.amount);
					shader_set_uniform_f_array(__PPF_SU.cinema_bars.colorr, __fx_cfg.cinema_bars.colorr);
					shader_set_uniform_f(__PPF_SU.cinema_bars.vertical_enable, __fx_cfg.cinema_bars.vertical_enable);
					shader_set_uniform_f(__PPF_SU.cinema_bars.horizontal_enable, __fx_cfg.cinema_bars.horizontal_enable);
					shader_set_uniform_f(__PPF_SU.cinema_bars.is_fixed, __fx_cfg.cinema_bars.is_fixed);
				}
				// > effect: color_blindness
				if (__fx_cfg.color_blindness.enabledd) {
					shader_set_uniform_f(__PPF_SU.color_blindness.mode, __fx_cfg.color_blindness.mode);
				}
				// > effect: channels
				if (__fx_cfg.channels.enabledd) {
					shader_set_uniform_f(__PPF_SU.channels.rgb, __fx_cfg.channels.red, __fx_cfg.channels.green, __fx_cfg.channels.blue);
				}
				// > [d] effect: border
				if (__fx_cfg.border.enabledd) {
					shader_set_uniform_f(__PPF_SU.border.curvature_f, __fx_cfg.border.curvature);
					shader_set_uniform_f(__PPF_SU.border.smooth_f, __fx_cfg.border.smooth);
					shader_set_uniform_f_array(__PPF_SU.border.colorr_f, __fx_cfg.border.colorr);
				}
				draw_surface_stretched(__stack_surface[__surf_index-1], 0, 0, view_w, view_h);
				shader_reset();
				
				gpu_set_blendmode(bm_normal);
				surface_reset_target();
			}
			#endregion
			
			// final render
			gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
			if (__is_draw_enabled) draw_surface_stretched(__stack_surface[__surf_index], x, y, w, h);
			//_pp_render_final_tex = surface_get_texture(__stack_surface[__surf_index]);
		} else {
			// default surface render
			gpu_set_blendenable(false);
			if (__is_draw_enabled) draw_surface_stretched(surface, x, y, w, h);
			
		}
		gpu_set_blendenable(_sys_blendenable);
		gpu_set_blendmode(_sys_blendmode);
		surface_depth_disable(_sys_depth_disable);
	}
}

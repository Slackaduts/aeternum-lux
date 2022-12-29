
#region System

// effects enumerator
enum PP_EFFECT {
	ROTATION,
	ZOOM,
	SHAKE,
	LENS_DISTORTION,
	PIXELIZE,
	SWIRL,
	PANORAMA,
	SINE_WAVE,
	GLITCH,
	SHOCKWAVES,
	DISPLACEMAP,
	WHITE_BALANCE,
	BORDER,
	FXAA,
	SUNSHAFTS,
	BLOOM,
	DEPTH_OF_FIELD,
	MOTION_BLUR,
	BLUR_RADIAL,
	LUT3D,
	SHADOW_MIDTONE_HIGHLIGHT,
	EXPOSURE,
	POSTERIZATION,
	BRIGHTNESS,
	SATURATION,
	CONTRAST,
	TONE_MAPPING,
	LIFT_GAMMA_GAIN,
	HUE_SHIFT,
	COLORIZE,
	INVERT_COLORS,
	TEXTURE_OVERLAY,
	PALETTE_SWAP,
	BLUR_KAWASE,
	BLUR_GAUSSIAN,
	CHROMABER,
	MIST,
	SPEEDLINES,
	DITHERING,
	NOISE_GRAIN,
	VIGNETTE,
	NES_FADE,
	FADE,
	SCANLINES,
	CINEMA_BARS,
	COLOR_BLINDNESS,
	CHANNELS,
}

/// @ignore
function __ppfx_system() constructor {
	// base
	__stack_surface = array_create(12, -1);
	__surf_index = 0;
	__render_x = 0;
	__render_y = 0;
	__render_vw = 0;
	__render_vh = 0;
	__render_res = 1;
	__render_old_res = __render_res;
	__current_profile = noone;
	__source_surf_exists = true;
	__time = 0;
	
	// extra
	__sunshaft_small_surface = -1;
	__sunshaft_downscale = 0;
	__bloom_surface = array_create(16, -1);
	__dof_surface = array_create(5, -1);
	__kawase_blur_surface = array_create(16, -1);
	__gaussian_blur_ping_surface = -1;
	__gaussian_blur_pong_surface = -1;
	__gaussian_blur_downscale = 0;
	
	// confs
	__is_draw_enabled = true;
	__is_render_enabled = true;
	__global_intensity = 1;
	
	static __cleanup = function() {
		__ppf_surface_delete_array(__stack_surface);
		__ppf_surface_delete_array(__bloom_surface);
		__ppf_surface_delete_array(__dof_surface);
		__ppf_surface_delete_array(__kawase_blur_surface);
		__ppf_surface_delete(__gaussian_blur_ping_surface);
		__ppf_surface_delete(__gaussian_blur_pong_surface);
	}
	
	__effects_names = [
		"rotation",
		"zoom",
		"shake",
		"lens_distortion",
		"pixelize",
		"swirl",
		"panorama",
		"sine_wave",
		"glitch",
		"shockwaves",
		"displacemap",
		"white_balance",
		"border",
		"fxaa",
		"sunshafts",
		"bloom",
		"depth_of_field",
		"motion_blur",
		"blur_radial",
		"lut3d",
		"shadow_midtone_highlight",
		"exposure",
		"posterization",
		"brightness",
		"saturation",
		"contrast",
		"tone_mapping",
		"lift_gamma_gain",
		"hue_shift",
		"colorize",
		"invert_colors",
		"texture_overlay",
		"palette_swap",
		"blur_kawase",
		"blur_gaussian",
		"chromaber",
		"mist",
		"speedlines",
		"dithering",
		"noise_grain",
		"vignette",
		"nes_fade",
		"fade",
		"scanlines",
		"cinema_bars",
		"color_blindness",
		"channels",
	];
	
	__fx_cfg = {
		rotation : {
			enabledd : false,
		},
		zoom : {
			enabledd : false,
		},
		shake : {
			enabledd : false,
		},
		lens_distortion : {
			enabledd : false,
		},
		pixelize : {
			enabledd : false,
		},
		swirl : {
			enabledd : false,
		},
		panorama : {
			enabledd : false,
		},
		sine_wave : {
			enabledd : false,
		},
		glitch : {
			enabledd : false,
		},
		shockwaves : {
			enabledd : false,
		},
		displacemap : {
			enabledd : false,
		},
		white_balance : {
			enabledd : false,
		},
		fxaa : {
			enabledd : false,
		},
		sunshafts : {
			enabledd : false,
		},
		bloom : {
			enabledd : false,
		},
		depth_of_field : {
			enabledd : false,
		},
		motion_blur : {
			enabledd : false,
		},
		blur_radial : {
			enabledd : false,
		},
		lut3d : {
			enabledd : false,
		},
		shadow_midtone_highlight : {
			enabledd : false,
		},
		exposure : {
			enabledd : false,
		},
		posterization : {
			enabledd : false,
		},
		brightness : {
			enabledd : false,
		},
		saturation : {
			enabledd : false,
		},
		contrast : {
			enabledd : false,
		},
		tone_mapping : {
			enabledd : false,
		},
		lift_gamma_gain : {
			enabledd : false,
		},
		hue_shift : {
			enabledd : false,
		},
		colorize : {
			enabledd : false,
		},
		invert_colors : {
			enabledd : false,
		},
		texture_overlay : {
			enabledd : false,
		},
		palette_swap : {
			enabledd : false,
		},
		blur_kawase : {
			enabledd : false,
		},
		blur_gaussian : {
			enabledd : false,
		},
		chromaber : {
			enabledd : false,
		},
		mist : {
			enabledd : false,
		},
		speedlines : {
			enabledd : false,
		},
		dithering : {
			enabledd : false,
		},
		noise_grain : {
			enabledd : false,
		},
		vignette : {
			enabledd : false,
		},
		nes_fade : {
			enabledd : false,
		},
		fade : {
			enabledd : false,
		},
		scanlines : {
			enabledd : false,
		},
		cinema_bars : {
			enabledd : false,
		},
		color_blindness : {
			enabledd : false,
		},
		channels : {
			enabledd : false,
		},
		border : {
			enabledd : false,
		},
	};
	
	_pp_cfg_default = {};
	__ppf_struct_copy(__fx_cfg, _pp_cfg_default);
}
#endregion

#region Effects

function pp_rotation(enabled, angle=0) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		angle : angle,
	};
}

function pp_zoom(enabled, amount=1, center=[0.5, 0.5]) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		amount : amount,
		center : center,
	};
}

function pp_shake(enabled, speedd=0.25, magnitude=0.01, hspeedd=1, vspeedd=1) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		speedd : speedd,
		magnitude : magnitude,
		hspeedd : hspeedd,
		vspeedd : vspeedd,
	};
}

function pp_lens_distortion(enabled, amount=0) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		amount : amount,
	};
}

function pp_pixelize(enabled, amount=0.5, squares_max=20, steps=50) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		amount : amount,
		squares_max : squares_max,
		steps : steps,
	};
}

function pp_swirl(enabled, angle=35, radius=1, center=[0.5,0.5]) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		angle : angle,
		radius : radius,
		center : center,
	};
}

function pp_panorama(enabled, depthh=1, is_horizontal=true) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		depthh : depthh,
		is_horizontal : is_horizontal,
	};
}

function pp_sine_wave(enabled, speedd=0.5, amplitude=[0.02,0.02], frequency=[10,10], offset=[0,0]) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		speedd : speedd,
		amplitude : amplitude,
		frequency : frequency,
		offset : offset,
	};
}

function pp_glitch(enabled, speedd=1, block_size=0.9, interval=0.995, intensity=0.2, peak_amplitude1=2, peak_amplitude2=1.5) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		speedd : speedd,
		block_size : block_size,
		interval : interval,
		intensity : intensity,
		peak_amplitude1 : peak_amplitude1,
		peak_amplitude2 : peak_amplitude2,
	};
}

function pp_shockwaves(enabled, amount=0.1, aberration=0.1, prisma_lut_tex=undefined, texture=undefined) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		amount : amount,
		aberration : aberration,
		prisma_lut_tex : __ppf_is_undefined(prisma_lut_tex) ? __PPF_ST.default_shockwaves_prisma_lut : prisma_lut_tex,
		texture : __ppf_is_undefined(texture) ? __PPF_ST.default_normal : texture,
	};
}

function pp_displacemap(enabled, amount=0.1, zoom=1, speedd=0.1, angle=0, texture=undefined, offset=[0,0]) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		amount : amount,
		zoom : zoom,
		angle : angle,
		speedd : speedd,
		texture : __ppf_is_undefined(texture) ? __PPF_ST.default_normal : texture,
		offset : offset,
	};
}

function pp_white_balance(enabled, temperature=0, tint=0) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		temperature : temperature,
		tint : tint,
	};
}

function pp_fxaa(enabled, strength=2) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		strength : strength,
	};
}

function pp_sunshafts(enabled, position=[0.5, 0.5], center_smoothness=0.3, threshold=0.5, intensity=3, dimmer=1.4, scattering=0.5, noise_enable=false, rays_tiling=1, rays_speed=0.03, downscale=0.8, dual_textures=false, world_tex=undefined, sky_tex=undefined, noise_tex=__PPF_ST.noise_perlin) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		position : position,
		center_smoothness : center_smoothness,
		threshold : threshold,
		intensity : intensity,
		dimmer : dimmer,
		scattering : scattering,
		noise_enable : noise_enable,
		rays_tiling : rays_tiling,
		rays_speed : rays_speed,
		downscale : downscale,
		dual_textures : dual_textures,
		world_tex : __ppf_is_undefined(world_tex) ? __PPF_ST.empty_texture : world_tex,
		sky_tex : __ppf_is_undefined(sky_tex) ? __PPF_ST.empty_texture : sky_tex,
		noise_tex : noise_tex,
	};
}

function pp_bloom(enabled, iterations=5, threshold=0.4, intensity=4.5, colorr=c_white, dirt_enable=false, dirt_texture=undefined, dirt_intensity=2.5, dirt_scale=1, reduce_banding=true, high_quality=true, debug=false) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		iterations : iterations,
		threshold : threshold,
		intensity : intensity,
		colorr : __ppf_get_color_rgb(colorr),
		dirt_enable : dirt_enable,
		dirt_texture : __ppf_is_undefined(dirt_texture) ? __PPF_ST.default_dirt_lens : dirt_texture,
		dirt_intensity : dirt_intensity,
		dirt_scale : dirt_scale,
		reduce_banding : reduce_banding,
		high_quality : high_quality,
		debug : debug,
	};
}

function pp_depth_of_field(enabled, radius=10, intensity=1, shaped=false, blades_aperture=6, blades_angle=0, use_zdepth=false, zdepth_tex=undefined, focus_distance=0.2, focus_range=0.02, debug=false) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		radius : radius,
		intensity : intensity,
		shaped : shaped,
		blades_aperture : blades_aperture,
		blades_angle : blades_angle,
		use_zdepth : use_zdepth,
		zdepth_tex : __ppf_is_undefined(zdepth_tex) ? __PPF_ST.pixel_texture : zdepth_tex,
		focus_distance : focus_distance,
		focus_range : focus_range,
		debug : debug,
	};
}

function pp_motion_blur(enabled, angle=0, radius=0, center=[0.5,0.5], mask_power=0, mask_scale=1.2, mask_smoothness=1, overlay_texture=undefined) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		angle : angle,
		radius : radius,
		center : center,
		mask_power : mask_power,
		mask_scale : mask_scale,
		mask_smoothness : mask_smoothness,
		overlay_texture : __ppf_is_undefined(overlay_texture) ? __PPF_ST.empty_texture : overlay_texture,
	};
}

function pp_blur_radial(enabled, radius=0.5, inner=1.5, center=[0.5,0.5]) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		radius : radius,
		inner : inner,
		center : center,
	};
}

function pp_lut3d(enabled, texture, intensity, size=[512,512], squares=8) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		texture : texture,
		intensity : intensity,
		size : size,
		squares : squares
	};
}

function pp_shadow_midtone_highlight(enabled, shadow_color=c_white, midtone_color=c_white, highlight_color=c_white, shadow_range=0.93, highlight_range=0.66) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		shadow_color : __ppf_get_color_rgb(shadow_color),
		midtone_color : __ppf_get_color_rgb(midtone_color),
		highlight_color : __ppf_get_color_rgb(highlight_color),
		shadow_range : shadow_range,
		highlight_range : highlight_range,
	};
}

function pp_exposure(enabled, value=1) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		value : value,
	};
}

function pp_posterization(enabled, color_factor=8) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		color_factor : color_factor,
	};
}

function pp_brightness(enabled, value=1) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		value : value,
	};
}

function pp_saturation(enabled, value=1) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		value : value,
	};
}

function pp_contrast(enabled, value=1) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		value : value,
	};
}

function pp_tone_mapping(enabled, mode=0) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		mode : mode,
	};
}

function pp_lift_gamma_gain(enabled, lift_amount=1, gamma_amount=1, gain_amount=1, lift_color=c_white, gamma_color=c_white, gain_color=c_white) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		lift : [(color_get_red(lift_color)/255)*lift_amount, (color_get_green(lift_color)/255)*lift_amount, (color_get_blue(lift_color)/255)*lift_amount],
		gamma : [(color_get_red(gamma_color)/255)*gamma_amount, (color_get_green(gamma_color)/255)*gamma_amount, (color_get_blue(gamma_color)/255)*gamma_amount],
		gain : [(color_get_red(gain_color)/255)*gain_amount, (color_get_green(gain_color)/255)*gain_amount, (color_get_blue(gain_color)/255)*gain_amount],
	};
}

function pp_hue_shift(enabled, colorr) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		colorr : __ppf_get_color_hsv(colorr),
	};
}

function pp_colorize(enabled, colorr=c_white, intensity=1, darkness=0) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		colorr : __ppf_get_color_rgb(colorr),
		intensity : intensity,
		darkness : darkness,
	};
}

function pp_invert_colors(enabled, intensity=1) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		intensity : intensity,
	};
}

function pp_texture_overlay(enabled, intensity=1, zoom=1, texture=undefined) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		intensity : intensity,
		texture : __ppf_is_undefined(texture) ? __PPF_ST.default_overlay_tex : texture,
		zoom : zoom,
	};
}

function pp_palette_swap(enabled, row=1, flip=false, texture=undefined, pal_height=1, threshold=0, limit_colors=true) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		row : row,
		flip : flip,
		texture : __ppf_is_undefined(texture) ? __PPF_ST.default_palette : texture,
		pal_height : pal_height,
		threshold : threshold,
		limit_colors : limit_colors,
	};
}

function pp_blur_kawase(enabled, amount=0.3, mask_power=0, mask_scale=1, mask_smoothness=1, downscale=2, iterations=8) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		amount : amount,
		mask_power : mask_power,
		mask_scale : mask_scale,
		mask_smoothness : mask_smoothness,
		downscale : downscale,
		iterations : iterations,
	};
}

function pp_blur_gaussian(enabled, amount=0.3, mask_power=0, mask_scale=1, mask_smoothness=1, downscale=0.5) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		amount : amount,
		mask_power : mask_power,
		mask_scale : mask_scale,
		mask_smoothness : mask_smoothness,
		downscale : downscale,
	};
}

function pp_chromaber(enabled, intensity=5, angle=35, only_outer=true, center_radius=0, blur_enable=false, prisma_lut_tex=undefined) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		angle : angle,
		intensity : intensity,
		only_outer : only_outer,
		center_radius : center_radius,
		blur_enable : blur_enable,
		prisma_lut_tex : __ppf_is_undefined(prisma_lut_tex) ? __PPF_ST.default_chromaber_prisma_lut : prisma_lut_tex,
	};
}

function pp_mist(enabled, intensity=0.5, scale=0.5, tiling=1, speedd=0.2, angle=0, contrast=0.8, powerr=1, remap=0.8, colorr=c_white, mix=0, mix_threshold=0, noise_tex=undefined, offset=[0.0,0.0], fade_amount=0, fade_angle=270) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		intensity : intensity,
		scale : scale,
		tiling : tiling,
		speedd : speedd,
		angle : angle,
		contrast : contrast,
		powerr : powerr,
		remap : remap,
		colorr : __ppf_get_color_rgb(colorr),
		mix : mix,
		mix_threshold : mix_threshold,
		noise_tex : __ppf_is_undefined(noise_tex) ? __PPF_ST.noise_perlin : noise_tex,
		offset : offset,
		fade_amount : fade_amount,
		fade_angle : fade_angle,
	}
}

function pp_speedlines(enabled, scale=0.1, tiling=5, speedd=2, rot_speed=1, contrast=0.5, powerr=1, remap=0.8, colorr=c_white, mask_power=5, mask_scale=1.2, mask_smoothness=1, noise_tex=undefined) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		scale : scale,
		tiling : tiling,
		speedd : speedd,
		rot_speed : rot_speed,
		contrast : contrast,
		powerr : powerr,
		remap : remap,
		colorr : __ppf_get_color_rgb(colorr),
		mask_power : mask_power,
		mask_scale : mask_scale,
		mask_smoothness : mask_smoothness,
		noise_tex : __ppf_is_undefined(noise_tex) ? __PPF_ST.noise_simplex : noise_tex,
	};
}

function pp_dithering(enabled, threshold=0, strength=0.3, mode=0, coord_absolute=false, bayer_texture=undefined, bayer_size=8) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		threshold : threshold,
		strength : strength,
		mode : mode,
		coord_absolute : coord_absolute,
		bayer_texture : __ppf_is_undefined(bayer_texture) ? __PPF_ST.bayer_8x8 : bayer_texture,
		bayer_size : bayer_size,
	};
}

function pp_noise_grain(enabled, intensity=0.3, scale=1, mix=true, noise_tex=undefined) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		intensity : intensity,
		scale : scale,
		mix : mix,
		noise_tex : __ppf_is_undefined(noise_tex) ? __PPF_ST.noise_point : noise_tex,
	};
}

function pp_vignette(enabled, intensity=0.7, curvature=0.7, inner=0.7, outer=1.2, colorr=c_black, center=[0.5,0.5], rounded=false, linear=false) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		intensity : intensity,
		curvature : curvature,
		inner : inner,
		outer : outer,
		colorr : __ppf_get_color_rgb(colorr),
		center : center,
		rounded : rounded,
		linear : linear,
	};
}

function pp_nes_fade(enabled, amount=0, levels=8) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		amount : amount,
		levels : levels,
	};
}

function pp_scanlines(enabled, intensity=0.1, speedd=0.3, amount=0.7, colorr=c_black, mask_power=0, mask_scale=1.2, mask_smoothness=1) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		intensity : intensity,
		speedd : speedd,
		amount : amount,
		colorr : __ppf_get_color_rgb(colorr),
		mask_power : mask_power,
		mask_scale : mask_scale,
		mask_smoothness : mask_smoothness,
	};
}

function pp_fade(enabled, amount=0, colorr=c_black) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		amount : amount,
		colorr : __ppf_get_color_rgb(colorr),
	};
}

function pp_cinema_bars(enabled, amount=0.2, colorr=c_black, vertical_enable=true, horizontal_enable=false, is_fixed=true) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		amount : amount,
		colorr : __ppf_get_color_rgb(colorr),
		vertical_enable : vertical_enable,
		horizontal_enable : horizontal_enable,
		is_fixed : is_fixed,
	};
}

function pp_color_blindness(enabled, mode=0) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		mode : mode,
	};
}

function pp_channels(enabled, red=1, green=1, blue=1) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		red : red,
		green : green,
		blue : blue,
	};
}

function pp_border(enabled, curvature=0, smooth=0, colorr=c_black) constructor {
	effect_name = __ppf_effect_get_name(self);
	sets = {
		enabledd : enabled,
		curvature : curvature,
		smooth : smooth,
		colorr : __ppf_get_color_rgb(colorr),
	};
}

#endregion

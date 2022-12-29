
/*-------------------------------------------------------------------------------------------------
	These functions are independent, so if you delete them from the asset, nothing will happen.
-------------------------------------------------------------------------------------------------*/

/// @desc Draw part of the post-processing system surface in a rectangular area
/// @param {Real} x The x coordinate of where to draw the sprite.
/// @param {Real} y The y coordinate of where to draw the sprite.
/// @param {Real} w The width of the area
/// @param {Real} h The height of the area
/// @param {Real} x_offset Defined by position X, minus this offset variable. Use 0 in the GUI dimension
/// @param {Real} y_offset Defined by position Y, minus this offset variable. Use 0 in the GUI dimension
/// @param {Struct} pp_index The returned variable by ppfx_create()
/// @returns {Undefined}
function area_draw_rect(x, y, w, h, x_offset, y_offset, pp_index) {
	__ppf_exception(!ppfx_exists(pp_index), "Post-processing system does not exist.");
	var _surf = pp_index.__stack_surface[pp_index.__surf_index];
	if surface_exists(_surf) draw_surface_part(_surf, x-x_offset, y-y_offset, w, h, x, y);
}

/// @desc Draw a normal sprite, but its texture is the post-processing texture.
/// @param {Asset.GMSprite} sprite_mask The sprite index to be used as a mask. It can be any color. It will only be used to "cut" the surface.
/// @param {Real} subimg The subimg (frame) of the sprite to draw (image_index or -1 correlate to the current frame of animation in the object).
/// @param {Real} x The x coordinate of where to draw the sprite.
/// @param {Real} y The y coordinate of where to draw the sprite.
/// @param {Struct} pp_index The returned variable by ppfx_create()
/// @returns {Undefined}
function area_draw_sprite_mask(sprite_mask, subimg, x, y, pp_index) {
	__ppf_exception(!ppfx_exists(pp_index), "Post-processing system does not exist.");
	var _surf = pp_index.__stack_surface[pp_index.__surf_index];
	if surface_exists(_surf) {
		shader_set(__PPF_SH_SPRMSK);
		shader_set_uniform_f(__PPF_SU.mask_render_posres, pp_index.__render_x, pp_index.__render_y, pp_index.__render_vw, pp_index.__render_vh);
		texture_set_stage(__PPF_SU.mask_render_tex, surface_get_texture(_surf));
		draw_sprite(sprite_mask, subimg, x, y);
		shader_reset();
	}
}

/// @desc Draw a normal sprite extended, but its texture is the post-processing texture.
/// @param {Asset.GMSprite} sprite_mask The sprite index to be used as a mask. It can be any color. It will only be used to "cut" the surface.
/// @param {Real} subimg The subimg (frame) of the sprite to draw (image_index or -1 correlate to the current frame of animation in the object).
/// @param {Real} x The x coordinate of where to draw the sprite.
/// @param {Real} y The y coordinate of where to draw the sprite.
/// @param {Real} xscale The horizontal scaling of the sprite, as a multiplier: 1 = normal scaling, 0.5 is half etc...
/// @param {Real} yscale The vertical scaling of the sprite as a multiplier: 1 = normal scaling, 0.5 is half etc...
/// @param {Real} rot The rotation of the sprite. 0=right way up, 90=rotated 90 degrees counter-clockwise etc...
/// @param {Real} color The color of the sprite.
/// @param {Real} alpha The color of the sprite.
/// @param {Struct} pp_index The returned variable by ppfx_create()
/// @returns {Undefined}
function area_draw_sprite_ext_mask(sprite_mask, subimg, x, y, xscale, yscale, rot, color, alpha, pp_index) {
	__ppf_exception(!ppfx_exists(pp_index), "Post-processing system does not exist.");
	var _surf = pp_index.__stack_surface[pp_index.__surf_index];
	if surface_exists(_surf) {
		shader_set(__PPF_SH_SPRMSK);
		shader_set_uniform_f(__PPF_SU.mask_render_posres, pp_index.__render_x, pp_index.__render_y, pp_index.__render_vw, pp_index.__render_vh);
		texture_set_stage(__PPF_SU.mask_render_tex, surface_get_texture(_surf));
		draw_sprite_ext(sprite_mask, subimg, x, y, xscale, yscale, rot, color, alpha);
		shader_reset();
	}
}

/// @desc Draw a normal sprite stretched, but its texture is the post-processing texture.
/// @param {Asset.GMSprite} sprite_mask The sprite index to be used as a mask. It can be any color. It will only be used to "cut" the surface.
/// @param {Real} subimg The subimg (frame) of the sprite to draw (image_index or -1 correlate to the current frame of animation in the object).
/// @param {Real} x The x coordinate of where to draw the sprite.
/// @param {Real} y The y coordinate of where to draw the sprite.
/// @param {Real} w The width of the sprite.
/// @param {Real} h The height of the sprite.
/// @param {Struct} pp_index The returned variable by ppfx_create()
/// @returns {Undefined}
function area_draw_sprite_stretched_mask(sprite_mask, subimg, x, y, w, h, pp_index) {
	__ppf_exception(!ppfx_exists(pp_index), "Post-processing system does not exist.");
	var _surf = pp_index.__stack_surface[pp_index.__surf_index];
	if surface_exists(_surf) {
		shader_set(__PPF_SH_SPRMSK);
		shader_set_uniform_f(__PPF_SU.mask_render_posres, pp_index.__render_x, pp_index.__render_y, pp_index.__render_vw, pp_index.__render_vh);
		texture_set_stage(__PPF_SU.mask_render_tex, surface_get_texture(_surf));
		draw_sprite_stretched(sprite_mask, subimg, x, y, w, h);
		shader_reset();
	}
}

/// @desc Draw a normal sprite stretched extended, but its texture is the post-processing texture.
/// @param {Asset.GMSprite} sprite_mask The sprite index to be used as a mask. It can be any color. It will only be used to "cut" the surface.
/// @param {Real} subimg The subimg (frame) of the sprite to draw (image_index or -1 correlate to the current frame of animation in the object).
/// @param {Real} x The x coordinate of where to draw the sprite.
/// @param {Real} y The y coordinate of where to draw the sprite.
/// @param {Real} w The width of the sprite.
/// @param {Real} h The height of the sprite.
/// @param {Real} color The color of the sprite.
/// @param {Real} alpha The alpha of the sprite.
/// @param {Struct} pp_index The returned variable by ppfx_create()
/// @returns {Undefined}
function area_draw_sprite_stretched_ext_mask(sprite_mask, subimg, x, y, w, h, color, alpha, pp_index) {
	__ppf_exception(!ppfx_exists(pp_index), "Post-processing system does not exist.");
	var _surf = pp_index.__stack_surface[pp_index.__surf_index];
	if surface_exists(_surf) {
		shader_set(__PPF_SH_SPRMSK);
		shader_set_uniform_f(__PPF_SU.mask_render_posres, pp_index.__render_x, pp_index.__render_y, pp_index.__render_vw, pp_index.__render_vh);
		texture_set_stage(__PPF_SU.mask_render_tex, surface_get_texture(_surf));
		draw_sprite_stretched_ext(sprite_mask, subimg, x, y, w, h, color, alpha);
		shader_reset();
	}
}

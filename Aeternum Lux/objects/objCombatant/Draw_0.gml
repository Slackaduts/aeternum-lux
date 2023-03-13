/// @desc Breathing Animation

// Breath code
depth = -1000;

if canBreathe {
	var _xscale = 1.01 + ((sin(((current_time / room_speed) + breathOffset) * breathTime)) * 0.01);
	var _yscale = 1.02 + ((sin(((current_time / room_speed) + (breathOffset + 10)) * breathTime)) * 0.02);
	draw_sprite_ext(sprite_index, image_index, x, y, _xscale, _yscale, image_angle, image_blend, image_alpha);
} else {
	draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, image_blend, image_alpha);
};
//draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, false);
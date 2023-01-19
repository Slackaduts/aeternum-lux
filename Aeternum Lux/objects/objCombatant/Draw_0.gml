/// @desc Breathing Animation

// Breath code
depth = -1000;
draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, 1.04 + ((sin(((current_time / room_speed) + breathOffset) * breathTime)) * 0.04), image_angle, image_blend, image_alpha);
//draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, false);
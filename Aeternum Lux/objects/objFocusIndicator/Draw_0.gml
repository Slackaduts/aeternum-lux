/// @desc Oscillate Alpha
if indicatorState != indicatorStates.INVISIBLE {
draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, indicatorColor, 0.5 + ((sin((current_time / room_speed) * 0.5)) * 0.5));
};
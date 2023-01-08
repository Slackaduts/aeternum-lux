/// @desc Handle animation

scenePool.run();

image_xscale = width / sprite_width;
image_yscale = height / sprite_width;

if (image_index >= image_number - 1) instance_destroy();
image_index += animSpd / FRAME_RATE;
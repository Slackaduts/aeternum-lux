/// @desc Draw Debug Info
depth = -1;
draw_text_scribble(32, 32, "Real FPS = " + string(fps_real));
draw_text_scribble(32, 64, "FPS = " + string(fps));

if global.focusInstance != undefined {
	draw_text_scribble(32, 96, "x: " + string(global.focusInstance.x));
	draw_text_scribble(32, 128, "y: " + string(global.focusInstance.y));
	draw_text_scribble(32, 160, "depth: " + string(global.focusInstance.depth));
};
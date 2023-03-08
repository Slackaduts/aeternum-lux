/// @desc Set particle system depth every frame
part_system_depth(partSystem, getTrueDepth(bbox_bottom, -0.5));
depth = getTrueDepth(bbox_bottom);
var despawnBufferWidth = 128;
if !point_in_rectangle(x, y, objCamera.camX - despawnBufferWidth, objCamera.camY - despawnBufferWidth, objCamera.camX + (objCamera.viewWidth / objCamera.zoomFactor) + despawnBufferWidth, objCamera.camY + (objCamera.viewHeight / objCamera.zoomFactor) + despawnBufferWidth) {
	part_emitter_destroy_all(partSystem);
	emitters = [];
} else if !array_length(emitters) {
	for (var currEmitter = 0; currEmitter < array_length(emitter_types); currEmitter++) {
		array_push(emitters, part_emitter_create(partSystem));
	};
};
for (var currEmitter = 0; currEmitter < array_length(emitters); currEmitter++) {
	part_emitter_region(partSystem, emitters[currEmitter], x - 1, x + 1, y, y, ps_shape_ellipse, ps_distr_linear);
	part_emitter_stream(partSystem, emitters[currEmitter], emitter_types[currEmitter], 1);
};

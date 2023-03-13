/// @desc Set particle system depth every frame, if we have moved

// Depth sort, first time only. End of event will handle cases where we move.
if !partSysDepthSet {
	part_system_depth(partSystem, getTrueDepth(bbox_bottom, -0.5));
	depth = getTrueDepth(bbox_bottom);
	partSysDepthSet = true;
};

// Only cull particles twice a second
if partSysCullFrame == 0 {
	var _despawnBufferWidth = 64;
	var _minBorderX = objCamera.camX - _despawnBufferWidth;
	var _minBorderY = objCamera.camY - _despawnBufferWidth;
	var _maxBorderX = objCamera.camX + (objCamera.viewWidth / objCamera.zoomFactor) + _despawnBufferWidth;
	var _maxBorderY = objCamera.camY + (objCamera.viewHeight / objCamera.zoomFactor) + _despawnBufferWidth;
	
	var _inView = (x >= _minBorderX && x <= _maxBorderX) && (y >= _minBorderY && y <= _maxBorderY); //If we lie within visible range, with some buffer

	if !partSysEmpty && !_inView { //If we aren't visible and we haven't been culled, cull
		part_emitter_destroy_all(partSystem);
		emitters = [];
		partSysEmpty = true;

	} else if partSysEmpty && _inView { //If we are visible and have been culled, reactivate
		for (var currEmitter = 0; currEmitter < array_length(emitter_types); currEmitter++) {
			array_push(emitters, part_emitter_create(partSystem));
			part_emitter_region(partSystem, emitters[currEmitter], x - 1, x + 1, y, y, ps_shape_ellipse, ps_distr_linear);
			part_emitter_stream(partSystem, emitters[currEmitter], emitter_types[currEmitter], 1);
		};
		partSysEmpty = false;
	};
};

//Reset frame counter for culling particles
partSysCullFrame += 1;
if partSysCullFrame >= 30 partSysCullFrame = 0;

// Only change depth if we move
if partSysPastX != x || partSysPastY != y {
	part_system_depth(partSystem, getTrueDepth(bbox_bottom, -0.5));
	depth = getTrueDepth(bbox_bottom);
};







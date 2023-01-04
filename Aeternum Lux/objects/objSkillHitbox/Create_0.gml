/// @desc Create lifetime and out of bounds callback checks


function update_collider() {
	switch shape {
		case colliderShapes.ELLIPSE: sprite_index = sprColliderEllipse;
	break;
	
	default: sprite_index = sprColliderSquare;
	};
	image_xscale = width / sprite_width;
	image_yscale = height / sprite_width;
};

update_collider();

scenePool = new scene_pool();
//If our lifetime (durationFrames) has ended, destroy self
if durationFrames >= 0 var _callback = call_later(durationFrames, time_source_units_frames, function() {instance_destroy(id, true);});

//Check every 2 seconds if we are out of bounds, destroy self if we are
var _outOfBoundsCallback = call_later(2, time_source_units_seconds, function() {
	if global.focusObject != undefined && distance_to_object(global.focusObject) >= 2000 instance_destroy(id, true);
	show_debug_message("THIS IS STILL RUNNING");
}, true);
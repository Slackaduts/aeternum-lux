function gui_element(_x, _y, _width, _height, _sprite, _anchorData, _anchorParams = {}, _children = new indexable_struct(), _animated = true, _color = c_black) constructor {
	x = _x;
	y = _y;
	width = _width;
	height = _height;
	color = _color;
	sprite = _sprite;
	anchorData = _anchorData;
	anchorParams = _anchorParams;
	children = _children;
	hovered = false;
	active = true;
	visible = true;
	animated = _animated;
	alpha = 1;
	if animated alpha = 0;
	
	tweenDuration = 1;
	tweenCurve = animcurve_get_channel(anim_tweens, "Linear");
	tweenIncrement = 1 / (tweenDuration * FRAME_RATE);
	tweenPercent = 0;
	finishedTween = false;
	
	static add_child = function(_child = new gui_element(x, y, sprite, anchor, anchorParams, children)) {
		return children.add_item(_child);
	};


	static update = function() {
		var _names = variable_struct_get_names(anchorParams);

		for (var _index = 0; _index < array_length(_names); _index++) {
			var _name = _names[_index];
			self[$ _name] = anchorData[$ _name];
		};
		
		var _children = children.get_array();
		hovered = array_length(_children) == 0 && point_in_rectangle(mouse_x, mouse_y, x, y, x + width, y + height);
		
		for (var _index = 0; _index < array_length(_children); _index++) {
			var _child = _children[_index];
			_child.update()
		};
	};


	static trigger = function() {}; // This is the root type, this will do more in specific GUI types
	
	
	static close = function() {
		active = false;
	};


	static free = function() {
		var _children = children.get_array();
		for (var _index = 0; _index < array_length(_children); _index++) {
			var _child = _children[_index];
			_child.free();
		};

		delete self;
	};


	static draw = function() {
		if !visible exit;
		if animated && (!finishedTween || !active) {
			tweenPercent += tweenIncrement;
			if tweenPercent > 1 || tweenPercent < 0 {
				tweenPercent = clamp(tweenPercent, 0, 1);
				finishedTween = true;
				tweenIncrement *= -1;
			};
			alpha = tweenPercent;
		};
		draw_sprite_stretched_ext(sprite, -1, x, y, width, height, color, alpha);

		var _children = children.get_array();
		for (var _index = 0; _index < array_length(_children); _index++) {
			var _child = _children[_index];
			_child.draw();
		};
		
		if !active && finishedTween free();
	};
}



function gui_dialogue(): gui_element() constructor {
	
	
	
	
	
};
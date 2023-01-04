enum animationStates {
	IDLE,
	WALK,
	SLASH,
	SHOOT,
	CAST,
	THRUST,
	LAST	
};


#macro LPC_IDLE_INDEXES [	\
[143],	\
[104],	\
[117],	\
[130]	\
]

#macro LPC_WALK_INDEXES [	\
[145, 146, 147, 148, 149, 150, 151],	\
[106, 107, 108, 109, 110, 111, 112],	\
[119, 120, 121, 122, 123, 124, 125],	\
[132, 133, 134, 135, 136, 137, 138]		\
]

#macro LPC_SLASH_INDEXES [	\
[195, 196, 197, 198, 199, 200],	\
[156, 157, 158, 159, 160, 161],	\
[169, 170, 171, 172, 173, 174],	\
[182, 183, 184, 185, 186, 187]	\
]

#macro LPC_SHOOT_INDEXES [	\
[247, 248, 249, 250, 251, 252, 253, 254, 255, 256, 257, 258, 259],	\
[208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220],	\
[221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233],	\
[234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246]	\
]

#macro LPC_CAST_INDEXES [	\
[39, 40, 41, 42, 43, 44, 45],	\
[0, 1, 2, 3, 4, 5, 6],	\
[13, 14, 15, 16, 17, 18, 19],	\
[26, 27, 28, 29, 30, 31, 32]	\
]

#macro LPC_THRUST_INDEXES [	\
[91, 92, 93, 94, 95, 96, 97, 98],	\
[52, 53, 54, 55, 56, 57, 58, 59],	\
[65, 66, 67, 68, 69, 70, 71, 72],	\
[78, 79, 80, 81, 82, 83, 84, 85]	\
]

#macro LPC_ANIMATION_DATA [	\
LPC_IDLE_INDEXES,	\
LPC_WALK_INDEXES,	\
LPC_SLASH_INDEXES,	\
LPC_SHOOT_INDEXES,	\
LPC_CAST_INDEXES,	\
LPC_THRUST_INDEXES	\
]


/**
 * Converts a direction (degrees) value to an array index to access animation data.
 * @param {real} _direction Direction to convert, in degrees
 * @returns {real} Array Index
 */
function direction_to_anim_index(_direction) {
	var _clampedDirection = ~~((_direction) mod 360);
	var _cardinalDirection = 0;

	if _clampedDirection >= 315 || _clampedDirection < 45 _cardinalDirection = 0;
	else if _clampedDirection >= 45 && _clampedDirection < 135 _cardinalDirection = 1;
	else if _clampedDirection >= 135 && _clampedDirection < 225 _cardinalDirection = 2;
	else _cardinalDirection = 3;
	
	return _cardinalDirection;
};


/**
 * Animates the sprite of the caller instance based on supplied animation data.
 * @param {array} _data Animation data, see macros above
 * @param {real} _direction Direction of the sprite to use
 * @param {any*} _state Animation state, see animationStates enum
 */
function animate_sprite(_data, _direction, _state) {
	var _animData = _data[_state];
	var _index = direction_to_anim_index(_direction);
	var _spd = sprite_get_speed(sprite_index) / FRAME_RATE;
	
	var _length = array_length(_animData[_index]);
	if localFrame < _length - _spd {
		localFrame += _spd;
		animationEnd = false;
		
	} else {
		localFrame = 0;
		animationEnd = true;
	};
	
	image_index = _animData[_index][~~localFrame];
};
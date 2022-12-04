// Handles sprite animation with QSpriteEditor-style animation arrays
function animate_sprite(animationData, spriteDirection)
{

// Set frame according to the animation speed

var clampedDirection = ~~((spriteDirection) mod 360);
var cardinalDirection = 0;
if clampedDirection >= 315 || clampedDirection < 45 cardinalDirection = 0
else if clampedDirection >= 45 && clampedDirection < 135 cardinalDirection = 1
else if clampedDirection >= 135 && clampedDirection < 225 cardinalDirection = 2
else cardinalDirection = 3;

//var cardinalDirection = ~~((clampedDirection / 90) mod 4);
//if (cardinalDirection >= 4) cardinalDirection = cardinalDirection mod 4;
var animationLength = array_length(animationData[cardinalDirection]);
var animationSpd = sprite_get_speed(sprite_index) / FRAME_RATE;

// If we have reached the end of the desired animation, in the desired direction
if (localFrame < animationLength - animationSpd) 
{
	localFrame += animationSpd;
	animationEnd = false;
	
} else {
	localFrame = 0;
	animationEnd = true;
};

image_index = (animationData[cardinalDirection][~~localFrame]);

};


function animate_static_sprite(startIndex, animationLength)
{
	
	
	
};
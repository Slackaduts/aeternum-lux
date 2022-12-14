/// @desc Initialize Combatant Object
event_inherited();
image_speed = 0;

// Speed Values
xSpd = 0;
ySpd = 0;
spdWalk = 5;
pastX = x;
pastY = y;
collided = false;

//Steering/Navigation related values
position = new vector(x, y);
velocity = new vector(0, 0);
proxyVelocity = 0;
steeringForce = new vector(0, 0);
maxForce = spdWalk;

tweenManager = new TweenManager();
combatTweenManager = new TweenManager();
pastTweenVector = new vector(0, 0);


// input values
keyLeft = false;
keyRight = false;
keyUp = false;
keyDown = false;
keyJump = false;
keySprint = false;
keySkill1 = false;
keySkill2 = false;
keySkill3 = false;
keySkill4 = false;
keySkill5 = false;
keySkill6 = false;

checker = undefined;

// Movement values
inputDirection = 0;
inputMagnitude = 0;

// animation values
spr = sprPlayerNero;
localFrame = 0;

// arrays for animations
idleIndexes =
[
[143],
[104],
[117],
[130],
];

walkIndexes =
[
[145, 146, 147, 148, 149, 150, 151],
[106, 107, 108, 109, 110, 111, 112],
[119, 120, 121, 122, 123, 124, 125],
[132, 133, 134, 135, 136, 137, 138],
];

movement = use_tdmc();



// TODO: Make this a struct and implement these


followingObj = undefined;
minFollowDistance = 64;
maximumCrowding = 48;
mp_potential_settings(90, 5, 6, 1);

wanderPerlinX = random_range(0, 10000);
wanderPerlinY = random_range(0, 10000);
wanderPerlinIncrement = 5;

canBreathe = true;
maxbreathDistance = 1.15;
breathTime = random_range(0.15, 0.30);
breathOffset = irandom_range(1, 20);

combatant = new CombatantManager("Enemy");

scenePool = [];

dataToSave = [
	"x",
	"y",
	"position",
	"velocity",
	"proxyVelocity",
	"steeringForce",
	"maxForce"
];
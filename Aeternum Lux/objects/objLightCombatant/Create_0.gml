/// @desc init lights
event_inherited();

lightXOffset = 0;
lightYOffset = -12;

lights = [];

array_push(lights, new BulbLight(objLightController.renderer, sprLight, 0, x, y));

lights[0].blend = #ffff87;
lights[0].xscale = 0.5;
lights[0].yscale = 0.5;
lights[0].alpha = 0.8;
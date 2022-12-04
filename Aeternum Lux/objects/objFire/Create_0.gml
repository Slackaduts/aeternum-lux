/// @desc Init Fire Emitter, add light
event_inherited();
array_push(emitter_types, ptFire);

lights = [];

array_push(lights, new BulbLight(objLightController.renderer, sprLight, 0, x, y));

lights[0].blend = #ff8300;
lights[0].xscale = 0.75;
lights[0].yscale = 0.75;
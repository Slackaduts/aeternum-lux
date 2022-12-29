
/*---------------------------------------------------------------------------------
This object is nothing more than a sprite with normal map. Post-Processing FX will
distort the image according to the sprite. Be creative to do whatever you want with
this object (like apply a wave shader?). :)
---------------------------------------------------------------------------------*/

//curve = __ac_ppf_shockwave;
sprite = __spr_ppf_shockwave_normal;
angle = 0;
alpha = 1;
//index = 0;
//scale = 1;
//spd = 0.01;

curve_channel_scale = animcurve_get_channel(curve, 0);
curve_channel_alpha = animcurve_get_channel(curve, 1);
progress = 0;
image_scale = 0;
